import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';

class CommonInfoBody extends StatelessWidget {
  //TODO: Remove Common Info Body
  final IconData icon;
  final String text;

  const CommonInfoBody._({
    required this.icon,
    required this.text,
  });

  static const CommonInfoBody error = CommonInfoBody._(
    icon: AppIcons.error,
    text: AppStrings.infoBodyError,
  );

  static const CommonInfoBody empty = CommonInfoBody._(
    icon: AppIcons.empty,
    text: AppStrings.infoBodyEmpty,
  );

  static const CommonInfoBody permissionDenied = CommonInfoBody._(
    icon: AppIcons.permissionDenied,
    text: AppStrings.infoBodyPermissionDenied,
  );

  static const CommonInfoBody noCamera = CommonInfoBody._(
    icon: AppIcons.noCamera,
    text: AppStrings.infoBodyNoCamera,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizes.iconXXXL,
          ),
          SizedBox(
            width: AppSizes.infoBodyTextBoxWith,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
