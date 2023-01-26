import 'dart:async';
import 'dart:isolate';

import 'package:note_repository/models/isolate_message_pair.dart';
import 'package:note_repository/models/service.dart';

class IsolateService extends Service
    with Disposable, Stoppable, ValueNotifiable<IsolateMessagePair?> {
  final int id;

  IsolateService(this.id);

  static const _readyCheckDuration = Duration(milliseconds: 100);

  late ReceivePort _receivePort;
  late Isolate _isolate;
  late SendPort _sendPort;
  late StreamSubscription _messageStreamSubscription;

  bool _isBusy = true;

  late dynamic _lastSendedMessage;

  bool get isBusy => _isBusy;
  bool get isNotBusy => !_isBusy;

  @override
  void init() {
    super.initNotifier(null);
    super.init();
  }

  @override
  void dispose() {
    super.disposeNotifier();
    super.dispose();
  }

  @override
  Future<void> start() async {
    if (isRunning) return;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _isolateLifecycle,
      _receivePort.sendPort,
      debugName: 'Isolate $id',
    );
    _messageStreamSubscription = _receivePort.listen(_messageListener);
    await Future.doWhile(() async {
      await Future.delayed(_readyCheckDuration);
      return _isBusy;
    });
    super.start();
  }

  @override
  void stop() {
    _isBusy = true;
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    _messageStreamSubscription.cancel();
    super.stop();
  }

  void send(dynamic message) {
    if (_isBusy) throw ''; //TODO
    _isBusy = true;
    _lastSendedMessage = message;
    _sendPort.send(message);
  }

  void _messageListener(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
    } else {
      value = IsolateMessagePair(
        sendedMessage: _lastSendedMessage,
        receivedMessage: message,
      );
    }
    _isBusy = false;
  }

  static void _isolateLifecycle(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    await for (dynamic message in receivePort) {
      if (message is Function) {
        final result = await message.call();
        sendPort.send(result);
      }
    }
  }
}
