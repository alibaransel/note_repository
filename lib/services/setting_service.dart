import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';
import 'package:note_repository/constants/configurations/app_settings.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/models/setting_notifier.dart';
import 'package:note_repository/services/storage_service.dart';

class SettingService extends Service with Initable {
  factory SettingService() => _instance;
  SettingService._();
  static final SettingService _instance = SettingService._();

  late final SettingNotifier<ThemeMode> _themeModeNotifier;
  late final SettingNotifier<LayoutMode> _layoutModeNotifier;

  SettingNotifier<ThemeMode> get themeMode => _themeModeNotifier;
  SettingNotifier<LayoutMode> get layoutMode => _layoutModeNotifier;

  @override
  Future<void> init() async {
    if (isInitialized) return;
    final Map<String, dynamic> data = await StorageService.file.getData(AppPaths.settings);
    _themeModeNotifier = SettingNotifier(
      setting: AppSettings.themeMode,
      firstValue: ThemeMode.values.byName(data[AppKeys.themeMode] as String),
    );
    _layoutModeNotifier = SettingNotifier(
      setting: AppSettings.layoutMode,
      firstValue: LayoutMode.values.byName(data[AppKeys.layoutMode] as String),
    );
    super.init();
  }

  Future<void> setToDefaults() async {
    _themeModeNotifier.value = AppDefaults.themeMode;
    _layoutModeNotifier.value = AppDefaults.layoutMode;
  }
}
