import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/screens/camera_screen.dart';
import 'package:note_repository/interface/screens/group_screen.dart';
import 'package:note_repository/interface/screens/note_screen.dart';
import 'package:note_repository/interface/views/account_view.dart';
import 'package:note_repository/interface/screens/home_screen.dart';
import 'package:note_repository/interface/screens/login_screen.dart';
import 'package:note_repository/interface/screens/settings_screen.dart';
import 'package:note_repository/interface/views/create_group_view.dart';
import 'package:note_repository/models/message.dart';
import 'package:note_repository/models/service.dart';

class NavigationService extends Service {
  factory NavigationService() => _instance;
  static final NavigationService _instance = NavigationService._();
  NavigationService._();

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
          MaterialPageRoute(builder: (context) => navigationRoute.widget),
        );
        break;
      case NavigationRouteType.replacedScreen:
        final NavigatorState navigatorState = _navigatorKey.currentState!;
        navigatorState.popUntil((route) => route.isFirst);
        navigatorState.pushReplacement(
          MaterialPageRoute(builder: (context) => navigationRoute.widget),
        );
        break;
      case NavigationRouteType.bottomSheet:
        showModalBottomSheet(
          context: _context,
          isScrollControlled: true,
          barrierColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          builder: (context) => navigationRoute.widget,
        );
        break;
      case NavigationRouteType.popup:
        showCupertinoModalPopup(
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

class NavigationRoute {
  final NavigationRouteType type;
  final Widget widget;

  const NavigationRoute._({
    required this.type,
    required this.widget,
  });

  static const NavigationRoute login = NavigationRoute._(
    type: NavigationRouteType.replacedScreen,
    widget: LoginScreen(),
  );

  static const NavigationRoute home = NavigationRoute._(
    type: NavigationRouteType.replacedScreen,
    widget: HomeScreen(),
  );

  static const NavigationRoute settings = NavigationRoute._(
    type: NavigationRouteType.screen,
    widget: SettingsScreen(),
  );

  static const NavigationRoute addMedia = NavigationRoute._(
    type: NavigationRouteType.screen,
    widget: CameraScreen(),
  );

  static const NavigationRoute createGroup = NavigationRoute._(
    type: NavigationRouteType.bottomSheet,
    widget: CreateGroupView(),
  );

  static const NavigationRoute account = NavigationRoute._(
    type: NavigationRouteType.popup,
    widget: AccountView(),
  );

  factory NavigationRoute.group({
    required String groupPath,
    Color? backgroundColor,
    PreferredSizeWidget? appBar,
  }) {
    return NavigationRoute._(
      type: NavigationRouteType.screen,
      widget: GroupScreen(
        groupPath: groupPath,
        backgroundColor: backgroundColor,
        appBar: appBar,
      ),
    );
  }

  factory NavigationRoute.note(String notePath) {
    return NavigationRoute._(
      type: NavigationRouteType.screen,
      widget: NoteScreen(notePath),
    );
  }
}

enum NavigationRouteType {
  screen,
  replacedScreen,
  bottomSheet,
  popup,
}
