import 'package:flutter/material.dart';
import 'package:note_repository/constants/angles.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/services/orientation_service.dart';

class CommonAutoTurner extends StatefulWidget {
  final Widget child;

  const CommonAutoTurner({
    super.key,
    required this.child,
  });

  @override
  State<CommonAutoTurner> createState() => _CommonAutoTurnerState();
}

class _CommonAutoTurnerState extends State<CommonAutoTurner> {
  static const Curve _rotateAnimationCurve = AppCurves.rotate;
  static const Duration _rotateAnimationDuration = AppDurations.m;

  late int _angle;

  void _deviceOrientationListener() {
    if (!mounted) return;
    final int angleChange = OrientationService().angleChange;
    if (angleChange == 0) return;
    setState(() {
      _angle += angleChange;
    });
  }

  @override
  void initState() {
    super.initState();
    OrientationService().addListener(_deviceOrientationListener);
    _angle = OrientationService().value.angle;
  }

  @override
  void dispose() {
    OrientationService().removeListener(_deviceOrientationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: _rotateAnimationDuration,
      curve: _rotateAnimationCurve,
      turns: _angle / Angles.complete,
      child: widget.child,
    );
  }
}
