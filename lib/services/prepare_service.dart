import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/camera_service.dart';
import 'package:note_repository/services/setting_service.dart';
import 'package:note_repository/services/storage_service.dart';
import 'package:note_repository/services/system_service.dart';

class PrepareService {
  PrepareService._();

  static Future<void> beforeAppRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await StorageService.prepare();
    await SettingService().fetch();
  }

  static Future<void> onAppInit() async {
    const UIService().setDefaults();
  }

  static Future<void> onAppDispose() async {}

  static Future<void> onSplashScreen() async {
    await Firebase.initializeApp();
    await CameraService().fetch();
    await AccountService().fetch();
  }
}
