import 'package:flutter/material.dart';
import 'package:note_repository/models/service.dart';

class SystemService extends Service with Stoppable, WidgetsBindingObserver {
  factory SystemService() => _instance;
  static final _instance = SystemService._();
  SystemService._();

  final appState = ValueNotifier<AppLifecycleState?>(null);

  @override
  void start() {
    if (isRunning) return;
    WidgetsBinding.instance.addObserver(this);
    super.start();
  }

  @override
  void stop() {
    if (!isRunning) return;
    WidgetsBinding.instance.removeObserver(this);
    super.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appState.value = state;
  }
}
