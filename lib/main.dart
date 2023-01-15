import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_themes.dart';
import 'package:note_repository/interface/screens/splash_screen.dart';
import 'package:note_repository/services/prepare_service.dart';
import 'package:note_repository/services/setting_service.dart';

void main() async {
  await PrepareService.beforeAppRun();
  runApp(const App());
}

//TODO: String formatter
//TODO: Prepare service
//TODO: Data security
//TODO: Onboarding screen
//TODO: Check and optimize services
//TODO: Localization
//TODO: Theme (Color + Text Style)
//TODO: Change storage structure
//TODO: Downloading (With notification)
//TODO: Use receive_sharing_intent

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late ThemeMode _themeMode;

  void _themeModeListener() {
    if (!mounted) return;
    setState(() {
      _themeMode = SettingService().themeMode.value;
    });
  }

  @override
  void initState() {
    PrepareService.onAppInit();
    SettingService().themeMode.addListener(_themeModeListener);
    _themeMode = SettingService().themeMode.value;
    super.initState();
  }

  @override
  void dispose() {
    PrepareService.onAppDispose();
    SettingService().themeMode.removeListener(_themeModeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: AppStrings.appName,
      themeMode: _themeMode,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      home: const SplashScreen(),
    );
  }
}
