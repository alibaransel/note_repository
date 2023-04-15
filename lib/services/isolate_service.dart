import 'dart:async';
import 'dart:isolate';

import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/process_service.dart';

class IsolateService extends Service with Stoppable {
  IsolateService(this.id);
  final int id;

  late ReceivePort _receivePort;
  late Isolate _isolate;
  late SendPort _sendPort;
  late Stream<dynamic> _messageStream;

  bool _isBusy = true;

  bool get isBusy => _isBusy;
  bool get isNotBusy => !_isBusy;

  @override
  Future<void> start() async {
    if (isRunning) return;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _isolateLifecycle,
      _receivePort.sendPort,
      debugName: 'Isolate $id',
    );
    _messageStream = _receivePort.asBroadcastStream();
    _sendPort = await _messageStream.first as SendPort;
    _isBusy = false;
    super.start();
  }

  @override
  void stop() {
    _isBusy = true;
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    super.stop();
  }

  Future<T> runFunction<T>(FutureOr<T> function) async {
    if (_isBusy) throw Exception(''); //TODO
    _isBusy = true;
    _sendPort.send(function);
    final Completer<T> completer = Completer<T>();
    final StreamSubscription<dynamic> subscription =
        _messageStream.listen((message) => completer.complete(message as FutureOr<T>));
    final T message = await completer.future;
    await subscription.cancel();
    _isBusy = false;
    return message;
  }

  static Future<void> _isolateLifecycle(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    await for (final dynamic message in receivePort) {
      if (message is ProcessFunction) {
        final dynamic result = await message.call();
        sendPort.send(result);
      }
    }
  }
}
