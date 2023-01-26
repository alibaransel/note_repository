import 'package:flutter/material.dart';
import 'package:note_repository/models/service.dart';

class SystemService extends Service with Disposable, WidgetsBindingObserver {
  factory SystemService() => _instance;
  static final _instance = SystemService._();
  SystemService._();

  final appState = ValueNotifier<AppLifecycleState?>(null);

  @override
  void init() {
    if (isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    super.init();
  }

  @override
  void dispose() {
    if (!isInitialized) return;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appState.value = state;
  }

  @override
  @protected
  void didChangeAccessibilityFeatures() => super.didChangeAccessibilityFeatures();

  @override
  @protected
  void didChangeLocales(List<Locale>? locales) => super.didChangeLocales(locales);

  @override
  @protected
  void didChangeMetrics() => super.didChangeMetrics();

  @override
  @protected
  void didChangePlatformBrightness() => super.didChangePlatformBrightness();

  @override
  @protected
  void didChangeTextScaleFactor() => super.didChangeTextScaleFactor();

  @override
  @protected
  void didHaveMemoryPressure() => super.didHaveMemoryPressure();

  @override
  @protected
  Future<bool> didPopRoute() => super.didPopRoute();

  @override
  @protected
  Future<bool> didPushRoute(String route) => super.didPushRoute(route);

  @override
  @protected
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) =>
      super.didPushRouteInformation(routeInformation);
}
