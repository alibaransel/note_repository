import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:note_repository/constants/angles.dart';

class OrientationService extends ValueNotifier<DeviceOrientation> with WidgetsBindingObserver {
  factory OrientationService() => _instance;
  static final OrientationService _instance = OrientationService._();
  OrientationService._() : super(_defaultOrientation);

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
  void addListener(VoidCallback listener) {
    if (!hasListeners) _start();
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _stop();
  }

  @protected
  @override
  set value(DeviceOrientation newValue);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _stop();
        break;
      case AppLifecycleState.resumed:
        _start();
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  void _start() {
    _startListening();
  }

  Future<void> _stop() async {
    _notifyTimer.cancel();
    super.value = _defaultOrientation;
    angleChange = 0;
    await _stopListening();
  }

  void _startListening() {
    _nativeDeviceOrientationCommunicator.resume();
    _nativeOrientationStreamSubscription =
        _nativeOrientationStream.listen(_nativeOrientationListener);
  }

  Future<void> _stopListening() async {
    await _nativeDeviceOrientationCommunicator.pause();
    await _nativeOrientationStreamSubscription.cancel();
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
