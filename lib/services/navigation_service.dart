import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/enums/navigation_route_type.dart';
import 'package:note_repository/models/message.dart';
import 'package:note_repository/models/navigation_route.dart';
import 'package:note_repository/models/service.dart';

class NavigationService extends Service {
  factory NavigationService() => _instance;
  NavigationService._();
  static final NavigationService _instance = NavigationService._();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  BuildContext get _context => _navigatorKey.currentContext!;

  void hide() {
    _navigatorKey.currentState!.maybePop();
  }

  void show(NavigationRoute navigationRoute) {
    switch (navigationRoute.type) {
      case NavigationRouteType.screen:
        _navigatorKey.currentState!.push(
          MaterialPageRoute<dynamic>(builder: (context) => navigationRoute.widget),
        );
        break;
      case NavigationRouteType.replacedScreen:
        final NavigatorState navigatorState = _navigatorKey.currentState!;
        navigatorState.popUntil((route) => route.isFirst);
        navigatorState.pushReplacement(
          MaterialPageRoute<dynamic>(builder: (context) => navigationRoute.widget),
        );
        break;
      case NavigationRouteType.bottomSheet:
        showModalBottomSheet<void>(
          context: _context,
          isScrollControlled: true,
          barrierColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          builder: (context) => navigationRoute.widget,
        );
        break;
      case NavigationRouteType.popup:
        showCupertinoModalPopup<void>(
          context: _context,
          barrierColor: Colors.transparent,
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          builder: (context) => navigationRoute.widget,
        );
        break;
    }
  }

  void showSnackBar(Message message) {
    if (message.text.isEmpty) return;
    ScaffoldMessenger.of(_context).hideCurrentSnackBar();
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: AppDurations.snackBar,
        backgroundColor: Colors.transparent,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: AppSizes.snackBarHeight,
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spacingM,
                horizontal: AppSizes.spacingL,
              ),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadius,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    spreadRadius: AppSizes.shadowRadius,
                    blurRadius: AppSizes.shadowRadius,
                  )
                ],
              ),
              child: Text(
                message.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
