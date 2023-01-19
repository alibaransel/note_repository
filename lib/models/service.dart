import 'package:flutter/foundation.dart';

abstract class Service {}

abstract class Initable {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void init() {
    _isInitialized = true;
  }
}

abstract class Stoppable {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  void start() {
    _isRunning = true;
  }

  void stop() {
    _isRunning = false;
  }
}

abstract class AutoStoppable extends Stoppable {
  @protected
  @override
  void start() => super.start();

  @protected
  @override
  void stop() => super.stop();
}
