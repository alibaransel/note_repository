import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_themes.dart';
import 'package:note_repository/interface/screens/splash_screen.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/service_service.dart';
import 'package:note_repository/services/setting_service.dart';

void main() async {
  // TODO: Async operation before app run, be careful!
  await ServiceService.beforeAppRun();
  runApp(const App());
}
// TODO: Improve navigation
//TODO: Use FlutterFire CLI to recreate project with Firebase
//TODO: Data security
//TODO: Onboarding screen
//TODO: Check and optimize services
//TODO: Localization
//TODO: Theme (Color + Text Style)
//TODO: Change storage structure
//TODO: Downloading (With notification)
//TODO: Use receive_sharing_intent

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    ServiceService.onAppInit();
  }

  @override
  void dispose() {
    ServiceService.onAppDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingService().themeMode,
      builder: (_, themeMode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService().navigatorKey,
        title: AppStrings.appName,
        themeMode: themeMode,
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
