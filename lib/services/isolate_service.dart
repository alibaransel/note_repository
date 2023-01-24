import 'dart:async';
import 'dart:isolate';

import 'package:note_repository/models/service.dart';

class IsolateService extends Service
    with Disposable, Stoppable, ValueNotifiable<IsolateMessagePair?> {
  final ReceivePort _receivePort = ReceivePort();
  late final Isolate _isolate;
  late final SendPort _sendPort;
  late final StreamSubscription _messageStreamSubscription;

  bool _isBusy = false;

  late dynamic _lastSendedMessage;

  bool get isBusy => _isBusy; //TODO: Decide to naming (adjective and getter naming)

  @override
  Future<void> init() async {
    if (isInitialized) return;
    _isolate = await Isolate.spawn(_isolateLifecycle, _receivePort.sendPort);
    _messageStreamSubscription = _receivePort.listen(_messageListener);
    super.initNotifier(null);
    super.init();
  }

  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _isBusy = false;
    _messageStreamSubscription.cancel();
    super.disposeNotifier();
    super.dispose();
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
      value = IsolateMessagePair(sended: _lastSendedMessage, received: message);
      _isBusy = false;
    }
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

class IsolateMessagePair<ST, RT> {
  final ST sended;
  final RT received;

  const IsolateMessagePair({
    required this.sended,
    required this.received,
  });
}
