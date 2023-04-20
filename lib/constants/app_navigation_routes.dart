import 'package:flutter/widgets.dart';
import 'package:note_repository/enums/navigation_route_type.dart';
import 'package:note_repository/interface/screens/camera_screen.dart';
import 'package:note_repository/interface/screens/group_screen.dart';
import 'package:note_repository/interface/screens/home_screen.dart';
import 'package:note_repository/interface/screens/login_screen.dart';
import 'package:note_repository/interface/screens/note_screen.dart';
import 'package:note_repository/interface/screens/settings_screen.dart';
import 'package:note_repository/interface/views/account_view.dart';
import 'package:note_repository/interface/views/create_group_view.dart';
import 'package:note_repository/models/navigation_route.dart';
import 'package:note_repository/services/item_service.dart';

class AppNavigationRoutes {
  const AppNavigationRoutes._();

  static const NavigationRoute login = NavigationRoute(
    type: NavigationRouteType.replacedScreen,
    widget: LoginScreen(),
  );

  static const NavigationRoute home = NavigationRoute(
    type: NavigationRouteType.replacedScreen,
    widget: HomeScreen(),
  );

  static const NavigationRoute settings = NavigationRoute(
    type: NavigationRouteType.screen,
    widget: SettingsScreen(),
  );
/*
  static const NavigationRoute addMediaAndCamera = NavigationRoute(
    type: NavigationRouteType.screen,
    widget: CameraScreen(),
  );
  
  static const NavigationRoute createGroup = NavigationRoute(
    type: NavigationRouteType.bottomSheet,
    widget: CreateGroupView(),
  );
*/
  static const NavigationRoute account = NavigationRoute(
    type: NavigationRouteType.popup,
    widget: AccountView(),
  );

  static NavigationRoute addMediaAndCamera(GroupService groupService) {
    return NavigationRoute(
      type: NavigationRouteType.screen,
      widget: CameraScreen(groupService),
    );
  }

  static NavigationRoute createGroup(GroupService groupService) {
    return NavigationRoute(
      type: NavigationRouteType.bottomSheet,
      widget: CreateGroupView(groupService),
    );
  }

  //TODO: Remove methods from const class
  static NavigationRoute group({
    required String groupPath,
    required GroupService parentGroupService,
    Color? backgroundColor,
    PreferredSizeWidget? appBar,
  }) {
    return NavigationRoute(
      type: NavigationRouteType.screen,
      widget: GroupScreen(
        groupPath: groupPath,
        parentGroupService: parentGroupService,
        backgroundColor: backgroundColor,
        appBar: appBar,
      ),
    );
  }

  static NavigationRoute note({
    required String notePath,
    required GroupService groupService,
  }) {
    return NavigationRoute(
      type: NavigationRouteType.screen,
      widget: NoteScreen(
        notePath: notePath,
        groupService: groupService,
      ),
    );
  }
}
