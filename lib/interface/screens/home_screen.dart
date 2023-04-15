import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_app_bar.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/interface/screens/group_screen.dart';
import 'package:note_repository/services/navigation_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupScreen(
      groupPath: AppPaths.mainGroup,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar(
      centerTitles: false,
      useCommonBackground: true,
      titles: const [
        Hero(
          tag: AppKeys.appLogoTag,
          child: FlutterLogo(size: AppSizes.iconM),
        ),
        SizedBox(width: AppSizes.spacingM),
        Text(AppStrings.appName),
      ],
      actions: [
        CommonIconButton(
          size: AppSizes.buttonM,
          iconSize: AppSizes.iconM,
          icon: AppIcons.settings,
          iconHeroTag: AppKeys.settingIconTag,
          onTap: () => NavigationService().show(AppNavigationRoutes.settings),
        ),
      ],
    );
  }
}
