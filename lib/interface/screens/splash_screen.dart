import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/service_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _prepareAppInMinTime() {
    Future.wait([
      Future.delayed(AppDurations.splashMin),
      ServiceService.onSplashScreen(),
    ]).then((_) {
      NavigationService().show(
        AccountService().isLoggedIn ? AppNavigationRoutes.home : AppNavigationRoutes.login,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _prepareAppInMinTime();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return const Center(
      child: Hero(
        tag: AppKeys.appLogoTag,
        child: FlutterLogo(
          size: AppSizes.splashAppIcon,
        ),
      ),
    );
  }
}
