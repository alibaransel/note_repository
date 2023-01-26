import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/design/app_physics.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/interface/common/common_app_bar.dart';
import 'package:note_repository/interface/common/common_text.dart';
import 'package:note_repository/interface/customs/multiple_switch.dart';
import 'package:note_repository/models/account.dart';
import 'package:note_repository/models/setting.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/setting_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return const CommonAppBar(
      useCommonBackground: true,
      titles: [
        Hero(
          tag: AppKeys.settingIconTag,
          child: Icon(
            AppIcons.settings,
            size: AppSizes.iconM,
          ),
        ),
        SizedBox(width: AppSizes.spacingXS),
        Text(AppStrings.settingsTitle),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        top: AppSizes.spacingM + CommonAppBar.heightWithStatusBar(context),
        left: AppSizes.spacingM,
        right: AppSizes.spacingM,
        bottom: AppSizes.spacingM,
      ),
      physics: AppPhysics.mainWithAlwaysScroll,
      children: [
        _buildAccountCard(context),
        SettingCard(SettingService().themeMode),
        SettingCard(SettingService().layoutMode),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return const _AccountCard();
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final Account account = AccountService().account;

    return GestureDetector(
      onTap: () => NavigationService().show(AppNavigationRoutes.account),
      child: Container(
        height: AppSizes.xL,
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          children: [
            SizedBox(
              height: AppSizes.m,
              width: AppSizes.m,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: account.image,
              ),
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: CommonText(
                account.name,
                style: const TextStyle(fontSize: 25), //TODO: Use context theme
              ),
            ),
            const Icon(AppIcons.arrowForward),
          ],
        ),
      ),
    );
  }
}

class SettingCard extends StatelessWidget {
  final SettingNotifier settingNotifier;

  const SettingCard(this.settingNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    final Setting setting = settingNotifier.setting;

    return Container(
      height: AppSizes.xL,
      margin: const EdgeInsets.only(top: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                setting.icon,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.spacingM),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(setting.title),
                ],
              ),
            ],
          ),
          MultipleSwitch(settingNotifier),
        ],
      ),
    );
  }
}
