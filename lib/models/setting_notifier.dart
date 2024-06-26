import 'package:flutter/foundation.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/models/notifiers.dart';
import 'package:note_repository/models/setting.dart';
import 'package:note_repository/services/storage_service.dart';

class SettingNotifier<T extends Enum> extends SafeValueNotifier<T> {
  SettingNotifier({
    required this.setting,
    required T firstValue,
  }) : super(firstValue);
  final Setting<T> setting;

  @override
  @protected
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
