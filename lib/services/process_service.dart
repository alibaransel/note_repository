import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:note_repository/models/isolate_message_pair.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/isolate_service.dart';

typedef ProcessFunction<T> = FutureOr<T> Function();

class ProcessService extends Service with Disposable, AutoStoppable {
  factory ProcessService() => _instance;
  static final ProcessService _instance = ProcessService._();
  ProcessService._();

  //TODO: Implement this service to other services
  //TODO: Improve isolate spawn time
  static const int _willNotBeUsedIsolateCount = 1;
  static const Duration _resultCheckDuration = Duration(milliseconds: 100);
  static const Duration _processQueueCheckDuration = Duration(milliseconds: 100);
  static const Duration _busyIsolateCheckDuration = Duration(milliseconds: 100);

  final List<ProcessFunction> _processFunctionQueue = [];
  final Map<ProcessFunction, dynamic> _processResultsMap = {};

  late final int _maxIsolateCount;
  late final bool _multiIsolateSupported;
  late final List<IsolateService> _isolateServices;

  int _runningIsolateCount = 0;

  int get _availableIsolateCount =>
      _maxIsolateCount - _willNotBeUsedIsolateCount - _runningIsolateCount;
  bool get _hasAvailableIsolate => _availableIsolateCount > 0;

  @override
  Future<void> init() async {
    _maxIsolateCount = Platform.numberOfProcessors;
    _multiIsolateSupported = _maxIsolateCount > 1;
    _isolateServices = List.generate(_availableIsolateCount, (i) {
      final IsolateService isolateService = IsolateService(i);
      isolateService.init();
      return isolateService;
    });
    if (_hasAvailableIsolate) await _startIsolate(0);
    super.init();
  }

  @override
  void dispose() {
    for (IsolateService isolateService in _isolateServices) {
      isolateService.dispose();
    }
    super.dispose();
  }

  @override
  @protected
  void start() {
    if (isRunning) return;
    _processing();
    super.start();
  }

  @override
  @protected
  void stop() {
    if (!isRunning) return;
    for (int i = 1; i < _isolateServices.length; i++) {
      if (_isolateServices[i].isRunning) {
        _stopIsolate(i);
      }
    }
    super.stop();
  }

  Future<T> process<T extends Object?>(ProcessFunction<T> processFunction) async {
    if (!_multiIsolateSupported) return await processFunction();
    _processFunctionQueue.add(processFunction);
    if (!isRunning) start();
    await Future.doWhile(() async {
      await Future.delayed(_resultCheckDuration);
      return !_processResultsMap.containsKey(processFunction);
    });
    final result = _processResultsMap[processFunction];
    _processResultsMap.remove(processFunction);
    return result;
  }

  Future<void> _startIsolate(int id) async {
    if (!_hasAvailableIsolate) return;
    _runningIsolateCount += 1;
    await _isolateServices[id].start();
    _isolateServices[id].addListener(() => _messageListener(id)); //TODO
  }

  void _stopIsolate(int id) {
    _isolateServices[id].stop();
    _isolateServices[id].removeListener(() => _messageListener(id));
    _runningIsolateCount -= 1;
  }

  Future<void> _processing() async {
    await Future.doWhile(() async {
      if (_hasAvailableIsolate) {
        int extraNeededIsolateCount = _processFunctionQueue.length > 5 * _runningIsolateCount
            ? (_processFunctionQueue.length / 5).ceil() - _runningIsolateCount
            : 0;
        extraNeededIsolateCount = extraNeededIsolateCount > _availableIsolateCount
            ? _availableIsolateCount
            : extraNeededIsolateCount;
        final int firstIsolateId = _runningIsolateCount;
        for (int i = 0; i < extraNeededIsolateCount; i++) {
          _startIsolate(firstIsolateId + i);
        }
      }
      for (IsolateService isolateService in _isolateServices) {
        if (isolateService.isRunning && isolateService.isNotBusy) {
          if (_processFunctionQueue.isNotEmpty) {
            _sendProcess(isolateService);
          } else {
            _stopIsolate(isolateService.id);
          }
        }
      }
      await Future.delayed(_processQueueCheckDuration);
      return _processFunctionQueue.isNotEmpty;
    });
    await Future.doWhile(() async {
      await Future.delayed(_busyIsolateCheckDuration);
      for (IsolateService isolateService in _isolateServices) {
        if (isolateService.isRunning && isolateService.isBusy) return true;
      }
      return false;
    });
    stop();
  }

  void _sendProcess(IsolateService isolateService) {
    final ProcessFunction processFunction = _processFunctionQueue.first;
    _processFunctionQueue.removeAt(0);
    isolateService.send(processFunction);
  }

  void _messageListener(int isolateId) {
    final IsolateMessagePair messageData = _isolateServices[isolateId].value!;
    _processResultsMap[messageData.sendedMessage] = messageData.receivedMessage;
  }
}
