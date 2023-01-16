import 'package:flutter/material.dart';

class SystemService with WidgetsBindingObserver {
  factory SystemService() => _instance;
  static final _instance = SystemService._();
  SystemService._();

  final appState = ValueNotifier<AppLifecycleState?>(null);

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appState.value = state;
  }
}
