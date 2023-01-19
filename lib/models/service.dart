import 'package:flutter/foundation.dart';

abstract class Service {}

abstract class StaticService extends Service {}

abstract class InitableService extends Service {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void init() {
    _isInitialized = true;
  }
}

abstract class StoppableService extends InitableService {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  void start() {
    _isRunning = true;
  }

  void stop() {
    _isRunning = false;
  }
}

abstract class ProtectedStoppableService extends StoppableService {
  @protected
  @override
  void start() => super.start();

  @protected
  @override
  void stop() => super.stop();
}
