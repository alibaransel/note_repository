import 'dart:io';
import 'dart:isolate';

import 'package:note_repository/models/service.dart';

class ProcessService extends Service with Initable {
  factory ProcessService() => _instance;
  static final _instance = ProcessService._();
  ProcessService._();

  late final int _threadCount;
  late final int _maxUsableThreadCount;
  List<Isolate> isolates = [];
  //TODO: Remove prints

  @override
  Future<void> init() async {
    _threadCount = Platform.numberOfProcessors;
    _maxUsableThreadCount = _threadCount - 1;
    await _createIsolate(); //TODO
    super.init();
  }

  Future<void> _createIsolate() async {
    ReceivePort receivePort = ReceivePort();
    print("Isolate spawning");
    Isolate isolate = await Isolate.spawn(_isolateLifecycle, receivePort.sendPort);
    print("Isolate spawned");
    late final SendPort sendPort; //= await receivePort.first;
    receivePort.listen((data) {
      if (data is SendPort) {
        sendPort = data;
        print("Send port ready");
      }
      if (data == "done") {
        print("Function done verified");
      }
    });
    for (int i = 0; i < 3; i++) {
      print("$i Waiting");
      await Future.delayed(const Duration(seconds: 3));
      print("$i Sending function");
      sendPort.send(() {
        print(DateTime.now());
      });
      print("$i Function sended");
    }
    print("Stopping isolate");
    sendPort.send(null);
  }
}

void _isolateLifecycle(final SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();

  sendPort.send(receivePort.sendPort);

  await for (final message in receivePort) {
    if (message is Function) {
      message.call();
      sendPort.send("done");
    } else if (message == null) {
      break;
    }
  }
  print("Isolate exiting");
  Isolate.exit();
}
