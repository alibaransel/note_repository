import 'package:flutter/material.dart';

class AppPhysics {
  const AppPhysics._();

  static const ScrollPhysics main = BouncingScrollPhysics();
  static const ScrollPhysics mainWithAlwaysScroll = AlwaysScrollableScrollPhysics(parent: main);
}
