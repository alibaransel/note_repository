import 'package:flutter/services.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';

class SystemService {
  const SystemService();

  Future<void> _setOrientations(List<DeviceOrientation> deviceOrientations) async {
    await SystemChrome.setPreferredOrientations(deviceOrientations);
  }

  Future<void> _setUIMode(SystemUiMode systemUiMode, {List<SystemUiOverlay>? overlays}) async {
    await SystemChrome.setEnabledSystemUIMode(systemUiMode, overlays: overlays);
  }

  Future<void> setDefaults() async {
    await _setOrientations(AppDefaults.deviceOrientations);
    await _setUIMode(AppDefaults.systemUiMode);
  }

  Future<void> hideOverlays() async {
    await _setUIMode(SystemUiMode.leanBack); // TODO: Is it true? If false change to manuel []
  }

  Future<void> restoreOverlays() async {
    await _setUIMode(AppDefaults.systemUiMode);
  }
}
