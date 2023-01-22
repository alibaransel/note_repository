import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_icons.dart';

abstract class Message {
  final String text;

  const Message([this.text = '']);
}

class InfoMessage extends Message {
  const InfoMessage([super.text]);

  static const IconData icon = AppIcons.infoMassage;
  static const Color iconColor = AppColors.infoMessageIcon;
}

class ExceptionMessage extends Message implements Exception {
  const ExceptionMessage([super.text]);

  static const IconData icon = AppIcons.errorMassage;
  static const Color iconColor = AppColors.errorMessageIcon;
}
