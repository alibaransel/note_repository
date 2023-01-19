import 'package:flutter/material.dart';
import 'package:note_repository/models/service.dart';

class SystemService extends Service with Stoppable, WidgetsBindingObserver {
  factory SystemService() => _instance;
  static final _instance = SystemService._();
  SystemService._();

  final appState = ValueNotifier<AppLifecycleState?>(null);

  @override
  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appState.value = state;
  }
}
