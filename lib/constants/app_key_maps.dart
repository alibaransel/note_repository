import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/models/note.dart';

class AppKeyMaps {
  const AppKeyMaps._();

  static const Map<String, IconData> loginType = {
    AppKeys.google: AppIcons.google,
    AppKeys.apple: AppIcons.apple,
  };

  static const Map<NoteType, IconData> noteIcon = {
    NoteType.image: AppIcons.image,
    NoteType.video: AppIcons.video,
    NoteType.audio: AppIcons.audio,
  };

  static const Map<String, String> loginSnackBarText = {
    AppKeys.internetError: AppStrings.loginSnackBarInternetError,
    AppKeys.error: AppStrings.pleaseTryAgain,
    AppKeys.done: AppStrings.loginSnackBarDone,
  };

  static const Map<NoteType, String> noteTypePath = {
    NoteType.image: AppPaths.images,
    NoteType.video: AppPaths.videos,
    NoteType.audio: AppPaths.audios,
  };

  static const Map<NoteType, String> noteTypeFileExtension = {
    NoteType.image: AppPaths.imageFileExtension,
    NoteType.video: AppPaths.videoFileExtension,
    NoteType.audio: AppPaths.audioFileExtension,
  };
}
