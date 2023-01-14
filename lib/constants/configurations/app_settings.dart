import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/models/setting.dart';

class AppSettings {
  const AppSettings._();

  static const Setting<ThemeMode> themeMode = Setting(
    key: AppKeys.themeMode,
    icon: AppIcons.themeMode,
    title: AppStrings.themeMode,
    options: [
      Option(value: ThemeMode.system, icon: AppIcons.themeModeAuto, name: AppStrings.system),
      Option(value: ThemeMode.light, icon: AppIcons.themeModeLight, name: AppStrings.light),
      Option(value: ThemeMode.dark, icon: AppIcons.themeModeDark, name: AppStrings.dark),
    ],
  );

  static const Setting<LayoutMode> layoutMode = Setting(
    key: AppKeys.layoutMode,
    icon: AppIcons.layoutMode,
    title: AppStrings.layoutMode,
    options: [
      Option(value: LayoutMode.list, icon: AppIcons.layoutModeList, name: AppStrings.list),
      Option(value: LayoutMode.grid, icon: AppIcons.layoutModeGrid, name: AppStrings.grid),
    ],
  );
}

enum LayoutMode {
  list,
  grid,
}
