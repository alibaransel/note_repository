import 'package:flutter/foundation.dart';

abstract class Service {}

mixin Initable on Service {
  bool _isInitialized = false;

  @protected
  bool get isInitialized => _isInitialized;

  void init() {
    _isInitialized = true;
  }
}

mixin Stoppable on Service {
  bool _isRunning = false;

  @protected
  bool get isRunning => _isRunning;

  void start() {
    _isRunning = true;
  }

  void stop() {
    _isRunning = false;
  }
}

mixin AutoStoppable on Service {
  bool _isRunning = false;

  @protected
  bool get isRunning => _isRunning;

  @protected
  void start() {
    _isRunning = true;
  }

  @protected
  void stop() {
    _isRunning = false;
  }
}
