import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_auto_turner.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_text.dart';

class CommonIconButton extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool square;
  final bool autoTurn;
  final bool commonBackground;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData icon;
  final String iconHeroTag;
  final String? text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CommonIconButton({
    super.key,
    required this.size,
    required this.iconSize,
    this.square = false,
    this.autoTurn = false,
    this.commonBackground = false,
    this.foregroundColor,
    this.backgroundColor,
    required this.icon,
    this.iconHeroTag = '',
    this.text,
    this.onTap,
    this.onLongPress,
  });

  //TODO: Add tap feedbacks (animations, sounds and vibrations)

  @override
  Widget build(BuildContext context) {
    final bool hasText = (text != null);

    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingS),
        height: size,
        width: hasText && !square ? null : size,
        decoration: !commonBackground && square
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              )
            : ShapeDecoration(
                color: backgroundColor,
                shape: const StadiumBorder(),
              ),
        child: Flex(
          direction: square ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconHeroTag.isNotEmpty ? Hero(tag: iconHeroTag, child: _buildIcon()) : _buildIcon(),
            if (hasText) ...[
              const SizedBox(width: AppSizes.spacingS),
              CommonText(
                text!,
                style: TextStyle(color: foregroundColor),
              ),
            ]
          ],
        ),
      ),
    );
    if (commonBackground) {
      button = CommonBackground(
        borderRadius: square ? null : size / 2,
        child: button,
      );
    }
    if (autoTurn) button = CommonAutoTurner(child: button);
    return button;
  }

  Widget _buildIcon() {
    return Icon(
      icon,
      size: iconSize,
      color: foregroundColor,
    );
  }
}
