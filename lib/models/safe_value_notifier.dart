import 'package:flutter/foundation.dart';

class SafeValueNotifier<T> {
  late final ValueNotifier<T> _valueNotifier;

  @nonVirtual
  void initNotifier(T firstValue) => _valueNotifier = ValueNotifier(firstValue);

  T get value => _valueNotifier.value;

  set value(T newValue) => _valueNotifier.value = newValue;

  void addListener(VoidCallback listener) => _valueNotifier.addListener(listener);

  void removeListener(VoidCallback listener) => _valueNotifier.removeListener(listener);
}

class ProtectedSafeValueNotifier<T> extends SafeValueNotifier<T> {
  @protected
  @override
  set value(T newValue) => super.value = newValue;
}
