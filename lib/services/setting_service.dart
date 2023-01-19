import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';
import 'package:note_repository/constants/configurations/app_settings.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/models/setting.dart';
import 'package:note_repository/services/storage_service.dart';

class SettingService extends Service with Initable {
  factory SettingService() => _instance;
  static final SettingService _instance = SettingService._();
  SettingService._();

  late final SettingNotifier<ThemeMode> _themeModeNotifier;
  late final SettingNotifier<LayoutMode> _layoutModeNotifier;

  SettingNotifier<ThemeMode> get themeMode => _themeModeNotifier;
  SettingNotifier<LayoutMode> get layoutMode => _layoutModeNotifier;

  @override
  Future<void> init() async {
    final Map<String, dynamic> data = await StorageService.file.getData(AppPaths.settings);
    _themeModeNotifier = SettingNotifier(
      setting: AppSettings.themeMode,
      firstValue: ThemeMode.values.byName(data[AppKeys.themeMode]),
    );
    _layoutModeNotifier = SettingNotifier(
      setting: AppSettings.layoutMode,
      firstValue: LayoutMode.values.byName(data[AppKeys.layoutMode]),
    );
  }

  Future<void> setToDefaults() async {
    _themeModeNotifier.value = AppDefaults.themeMode;
    _layoutModeNotifier.value = AppDefaults.layoutMode;
  }
}

class SettingNotifier<T extends Enum> extends ValueNotifier<T> {
  final Setting<T> setting;

  SettingNotifier({
    required this.setting,
    required T firstValue,
  }) : super(firstValue);

  @override
  set value(T newValue) {
    if (newValue == value) return;
    super.value = newValue;
    StorageService.file.updateData(
      path: AppPaths.settings,
      newData: {
        setting.key: newValue.name,
      },
    );
  }
}
