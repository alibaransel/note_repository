import 'dart:async';
import 'dart:io';

import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/isolate_service.dart';

typedef ProcessFunction<T> = FutureOr<T> Function();

class ProcessService extends Service with Initable {
  factory ProcessService() => _instance;
  static final _instance = ProcessService._();
  ProcessService._();

  //TODO: Implement this service to other services
  //TODO: Research solution whitch is better then while-delay
  static const _resultCheckDuration = Duration(milliseconds: 100);
  static const _processQueueCheckDuration = Duration(milliseconds: 100);

  final List<ProcessFunction> _processFunctionQueue = [];
  final Map<ProcessFunction, dynamic> _processResultsMap = {};

  late final int _maxIsolateCount;
  late final bool _multiIsolateSupported;

  late IsolateService _isolateService; //TODO: Make list

  bool _isProcessing = false;
  int _busyIsolateCount = 1;

  int get _availableIsolateCount => _maxIsolateCount - _busyIsolateCount;
  bool get _hasAvailableIsolate => _availableIsolateCount > 0;

  @override
  Future<void> init() async {
    _maxIsolateCount = Platform.numberOfProcessors;
    _multiIsolateSupported = _maxIsolateCount > 1;
    if (_hasAvailableIsolate) await _createIsolate();
    super.init();
  }

  Future<T> process<T extends Object?>(ProcessFunction<T> processFunction) async {
    if (!_multiIsolateSupported) return processFunction();
    _processFunctionQueue.add(processFunction);
    if (!_isProcessing) _startProcessing();
    while (true) {
      if (_processResultsMap.containsKey(processFunction)) break;
      await Future.delayed(_resultCheckDuration);
    }
    final result = _processResultsMap[processFunction];
    _processResultsMap.remove(processFunction);
    return result;
  }

  Future<void> _createIsolate() async {
    if (!_hasAvailableIsolate) return;
    _busyIsolateCount += 1;
    final IsolateService isolateService = IsolateService();
    await isolateService.init();
    isolateService.addListener(_messageListener);
    _isolateService = isolateService;
  }

  _startProcessing() {
    _isProcessing = true;
    return _processing();
  }

  _processing() async {
    while (_processFunctionQueue.isNotEmpty) {
      if (!_isolateService.isBusy) {
        final ProcessFunction processFunction = _processFunctionQueue.first;
        _processFunctionQueue.removeAt(0);
        _isolateService.send(processFunction);
      }
      await Future.delayed(_processQueueCheckDuration);
    }
    _isProcessing = false;
  }

  _messageListener() {
    final IsolateMessagePair messagePair = _isolateService.value!;
    _processResultsMap[messagePair.sended] = messagePair.received;
  }
}
