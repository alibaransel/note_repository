import 'package:flutter/foundation.dart';
import 'package:note_repository/models/notifiers.dart';

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

mixin ChangeNotifiable on Service {
  final _changeNotifier = OpenChangeNotifier();

  @protected
  @nonVirtual
  bool get hasListeners => _changeNotifier.hasListeners;

  @mustCallSuper
  void addListener(VoidCallback listener) => _changeNotifier.addListener(listener);

  @mustCallSuper
  void removeListener(VoidCallback listener) => _changeNotifier.removeListener(listener);

  @protected
  @mustCallSuper
  void notifyListeners() => _changeNotifier.notifyListeners();

  @protected
  @nonVirtual
  void disposeNotifier() => _changeNotifier.dispose();
}

mixin ValueNotifiable<T> on Service {
  late final OpenValueNotifier<T> _valueNotifier;

  @protected
  @nonVirtual
  bool get hasListener => _valueNotifier.hasListeners;

  @nonVirtual
  T get value => _valueNotifier.value;

  @protected
  @nonVirtual
  void initNotifier(T firstValue) => _valueNotifier = OpenValueNotifier(firstValue);

  @protected
  @nonVirtual
  set value(T newValue) => _valueNotifier.value = newValue;

  @mustCallSuper
  void addListener(VoidCallback listener) => _valueNotifier.addListener(listener);

  @mustCallSuper
  void removeListener(VoidCallback listener) => _valueNotifier.removeListener(listener);

  @protected
  @nonVirtual
  void disposeNotifier() => _valueNotifier.dispose();
}
