import 'package:flutter/services.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';

class UIService {
  UIService._();

  static Future<void> _setOrientations(List<DeviceOrientation> deviceOrientations) async {
    await SystemChrome.setPreferredOrientations(deviceOrientations);
  }

  static Future<void> _setUIMode(
    SystemUiMode systemUiMode, {
    List<SystemUiOverlay>? overlays,
  }) async {
    await SystemChrome.setEnabledSystemUIMode(systemUiMode, overlays: overlays);
  }

  static Future<void> setDefaults() async {
    await _setOrientations(AppDefaults.deviceOrientations);
    await _setUIMode(AppDefaults.systemUiMode);
  }

  static Future<void> hideOverlays() async {
    await _setUIMode(SystemUiMode.leanBack);
  }

  static Future<void> restoreOverlays() async {
    await _setUIMode(AppDefaults.systemUiMode);
  }
}
