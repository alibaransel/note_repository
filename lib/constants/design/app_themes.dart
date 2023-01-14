import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/design/app_colors.dart';

class AppThemes {
  const AppThemes._();

  static const _textTheme = TextTheme();

  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.mainColor,
    scaffoldBackgroundColor: AppColors.white,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      foregroundColor: AppColors.black,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: false,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: Colors.black,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.black,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.mainColor,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: false,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.white,
    ),
  );
}
