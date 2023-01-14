import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_sizes.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final Color? backgroundColor;

  const CommonBackground({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.borderRadius),
      child: ColoredBox(
        color: backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor.withOpacity(AppColors.backgroundOpacityS),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSizes.blurSigma,
            sigmaY: AppSizes.blurSigma,
          ),
          child: child,
        ),
      ),
    );
  }
}
