import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_id_codes.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/note.dart';

class AppIdCodeMaps {
  const AppIdCodeMaps._();

  static const codeTypeMap = <String, Map<String, dynamic>>{
    AppIdCodes.item: _itemType,
    AppIdCodes.color: _color,
    AppIdCodes.noteType: _noteType,
  };

  static const Map<String, Type> _itemType = {
    AppIdCodes.group: Group,
    AppIdCodes.note: Note,
  };

  static const Map<String, Color> _color = <String, Color>{
    AppIdCodes.red: AppColors.groupRed,
    AppIdCodes.orange: AppColors.groupOrange,
    AppIdCodes.yellow: AppColors.groupYellow,
    AppIdCodes.green: AppColors.groupGreen,
    AppIdCodes.cyan: AppColors.groupCyan,
    AppIdCodes.blue: AppColors.groupBlue,
    AppIdCodes.purple: AppColors.groupPurple,
  };

  static const Map<String, NoteType> _noteType = {
    AppIdCodes.image: NoteType.image,
    AppIdCodes.video: NoteType.video,
    AppIdCodes.audio: NoteType.audio,
  };
}
