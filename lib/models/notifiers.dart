import 'package:flutter/foundation.dart';

class OpenChangeNotifier extends ChangeNotifier {
  @override
  @nonVirtual
  bool get hasListeners => super.hasListeners;

  @override
  @mustCallSuper
  void notifyListeners() => super.notifyListeners();
}

class SafeChangeNotifier extends ChangeNotifier {
  @override
  @protected
  @nonVirtual
  bool get hasListeners => super.hasListeners;

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) => super.addListener(listener);

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) => super.removeListener(listener);

  @override
  @protected
  @mustCallSuper
  void notifyListeners() => super.notifyListeners();

  @override
  @protected
  @nonVirtual
  void dispose() => super.dispose();
}

class OpenValueNotifier<T> extends ValueNotifier<T> {
  OpenValueNotifier(super.value);

  @override
  bool get hasListeners => super.hasListeners;
}

class SafeValueNotifier<T> extends ValueNotifier<T> {
  SafeValueNotifier(super.value);

  @override
  @protected
  @nonVirtual
  bool get hasListeners => super.hasListeners;

  @override
  @nonVirtual
  T get value => super.value;

  @override
  @protected
  set value(T newValue) => super.value = newValue;

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) => super.addListener(listener);

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) => super.removeListener(listener);

  @override
  @protected
  @nonVirtual
  void dispose() => super.dispose();
}
