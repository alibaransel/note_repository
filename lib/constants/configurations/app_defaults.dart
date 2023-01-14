import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/configurations/app_settings.dart';
import 'package:note_repository/services/path_service.dart';

class AppDefaults {
  const AppDefaults._();

  static final List<String> directoryPaths = [
    AppPaths.core,
    AppPaths.app,
    AppPaths.files,
    AppPaths.user,
    AppPaths.noteFiles,
    AppPaths.images,
    AppPaths.videos,
    AppPaths.audios,
    AppPaths.mainGroup,
    PathService().groupGroups('${AppPaths.mainGroup}/'),
    PathService().groupNotes('${AppPaths.mainGroup}/')
  ];

  static final Map<String, Map<String, dynamic>> filePathsAndData = {
    AppPaths.config: {},
    AppPaths.account: {},
    AppPaths.settings: {
      AppSettings.themeMode.key: themeMode.name,
      AppSettings.layoutMode.key: layoutMode.name,
    },
    PathService().groupGroupIds(AppPaths.mainGroup): {
      AppKeys.data: <String>[],
    },
    PathService().groupNoteIds(AppPaths.mainGroup): {
      AppKeys.data: <String>[],
    },
  };

  //Settings
  static const ThemeMode themeMode = ThemeMode.system;
  static const LayoutMode layoutMode = LayoutMode.grid;

  static const FlashMode flashMode = FlashMode.off;
  static const FocusMode focusMode = FocusMode.auto;
  static const ExposureMode exposureMode = ExposureMode.auto;

  static const SystemUiMode systemUiMode = SystemUiMode.edgeToEdge;
  static const List<DeviceOrientation> deviceOrientations = [
    DeviceOrientation.portraitUp,
  ];
}
