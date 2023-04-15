import 'package:flutter/widgets.dart';
import 'package:note_repository/enums/navigation_route_type.dart';

class NavigationRoute {
  const NavigationRoute({
    required this.type,
    required this.widget,
  });
  final NavigationRouteType type;
  final Widget widget;
}
