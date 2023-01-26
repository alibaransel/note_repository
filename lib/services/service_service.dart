import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/camera_service.dart';
import 'package:note_repository/services/process_service.dart';
import 'package:note_repository/services/setting_service.dart';
import 'package:note_repository/services/storage_service.dart';
import 'package:note_repository/services/system_service.dart';
import 'package:note_repository/services/ui_service.dart';

class ServiceService extends Service {
  ServiceService._();

  static Future<void> beforeAppRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ProcessService().init();
    await StorageService().init();
    await SettingService().init();
  }

  static Future<void> onAppInit() async {
    SystemService().init();
    await UIService.setDefaults();
  }

  static void onAppDispose() {
    SystemService().dispose();
  }

  static Future<void> onSplashScreen() async {
    await Firebase.initializeApp();
    await CameraService().fetch();
    await AccountService().init();
  }
}
