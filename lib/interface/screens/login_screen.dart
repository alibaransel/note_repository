import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/app_exceptions.dart';
import 'package:note_repository/constants/app_info_messages.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_loading_indicator.dart';
import 'package:note_repository/models/message.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _buttonStatus = true;

  Future<void> _googleButtonOnClick() async {
    setState(() {
      _buttonStatus = false;
    });
    try {
      await AccountService().login();
      NavigationService().show(AppNavigationRoutes.home);
      NavigationService().showSnackBar(AppInfoMessages.loginDone);
    } catch (e) {
      NavigationService().showSnackBar(e is ExceptionMessage ? e : AppExceptions.error);
    }
    setState(() {
      _buttonStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Hero(
                tag: AppKeys.appLogoTag,
                child: FlutterLogo(size: AppSizes.iconXXXL),
              ),
              const SizedBox(height: AppSizes.spacingL),
              const Text(
                AppStrings.login,
                //TODO: Create Text Theme
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: AppSizes.spacingL),
              _buildGoogleButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return GestureDetector(
      onTap: () async => _buttonStatus ? _googleButtonOnClick() : () {},
      child: Container(
        height: AppSizes.xL,
        width: AppSizes.xL,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.secondaryColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.m,
          child: _buttonStatus
              ? const Icon(
                  AppIcons.google,
                  size: AppSizes.iconXL,
                )
              : const CommonLoadingIndicator(),
        ),
      ),
    );
  }
}
