import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:note_repository/constants/angles.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/system_service.dart';

class OrientationService extends Service
    with Disposable, AutoStoppable, ValueNotifiable<DeviceOrientation> {
  factory OrientationService() => _instance;
  static final OrientationService _instance = OrientationService._();
  OrientationService._();

  static const DeviceOrientation _defaultOrientation = DeviceOrientation.portraitUp;
  static const Duration _waitDurationBeforeNotify = Duration(milliseconds: 400);

  static final NativeDeviceOrientationCommunicator _nativeDeviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator()..pause();

  final Stream<NativeDeviceOrientation> _nativeOrientationStream =
      _nativeDeviceOrientationCommunicator.onOrientationChanged(useSensor: true).distinct();

  int angleChange = 0;
  Timer _notifyTimer = Timer(Duration.zero, () {});

  late StreamSubscription<NativeDeviceOrientation> _nativeOrientationStreamSubscription;

  @override
  void init() {
    if (isInitialized) return;
    super.initNotifier(_defaultOrientation);
    super.init();
  }

  @override
  void dispose() {
    if (isNotInitialized) return;
    super.disposeNotifier();
    super.dispose();
  }

  @override
  @protected
  void start() {
    if (isRunning) return;
    SystemService().appState.addListener(_appStateListener);
    _nativeDeviceOrientationCommunicator.resume();
    _nativeOrientationStreamSubscription =
        _nativeOrientationStream.listen(_nativeOrientationListener);
    super.start();
  }

  @override
  @protected
  Future<void> stop() async {
    if (isNotRunning) return;
    _notifyTimer.cancel();
    super.value = _defaultOrientation;
    angleChange = 0;
    SystemService().appState.removeListener(_appStateListener);
    await _nativeDeviceOrientationCommunicator.pause();
    await _nativeOrientationStreamSubscription.cancel();
    super.stop();
  }

  @override
  void addListener(VoidCallback listener) {
    if (super.hasNoListeners) start();
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (super.hasNoListeners) stop();
  }

  void _appStateListener() {
    switch (SystemService().appState.value) {
      case AppLifecycleState.paused:
        stop();
        break;
      case AppLifecycleState.resumed:
        start();
        break;
      default:
    }
  }

  void _nativeOrientationListener(NativeDeviceOrientation nativeOrientation) {
    _notifyTimer.cancel();
    _notifyTimer = Timer(
      _waitDurationBeforeNotify,
      () => _update(nativeOrientation),
    );
  }

  void _update(NativeDeviceOrientation nativeOrientation) {
    final DeviceOrientation newOrientation = nativeOrientation.converted;
    angleChange = newOrientation.angle - super.value.angle;
    if (angleChange.abs() == Angles.right * 3) angleChange = -angleChange.sign * Angles.right;
    super.value = newOrientation;
    angleChange = 0;
  }
}

extension OrientationAngle on DeviceOrientation {
  int get angle => index * Angles.right;
}

extension _ConvertToDeviceOrientation on NativeDeviceOrientation {
  DeviceOrientation get converted {
    switch (this) {
      case NativeDeviceOrientation.unknown:
      case NativeDeviceOrientation.portraitUp:
        return DeviceOrientation.portraitUp;
      case NativeDeviceOrientation.portraitDown:
        return DeviceOrientation.portraitDown;
      case NativeDeviceOrientation.landscapeLeft:
        return DeviceOrientation.landscapeLeft;
      case NativeDeviceOrientation.landscapeRight:
        return DeviceOrientation.landscapeRight;
    }
  }
}
