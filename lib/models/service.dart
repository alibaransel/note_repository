//TODO: Research and improve

import 'package:flutter/foundation.dart';

abstract class Service {}

abstract class InitableService extends Service with _Initable {}

abstract class StoppableService extends Service with _Stoppable {}

abstract class InitableStoppableService extends Service with _Initable, _Stoppable {}

mixin _Initable on Service {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  @mustCallSuper
  void init() {
    _initialized = true;
  }
}

mixin _Stoppable on Service {
  bool _running = false;

  bool get isRunning => _running;

  @protected
  @mustCallSuper
  void start() {
    _running = true;
  }

  @protected
  @mustCallSuper
  void stop() {
    _running = false;
  }
}
