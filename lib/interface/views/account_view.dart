import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_info_messages.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/app_key_maps.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/models/account.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/account_service.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final Account account = AccountService().account;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          height: AppSizes.popUp,
          width: AppSizes.popUp,
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: AppSizes.shadowRadius,
                blurRadius: AppSizes.shadowRadius,
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: AppSizes.googleAccountImage,
                      width: AppSizes.googleAccountImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        child: account.image,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      account.name,
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppKeyMaps.loginType[account.loginType],
                          size: AppSizes.iconM,
                        ),
                        Text(
                          account.email,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await AccountService().logOut(); //TODO: Implement exception and error conditions
                  NavigationService().show(NavigationRoute.login);
                  NavigationService().showSnackBar(AppInfoMessages.logoutDone);
                },
                child: Container(
                  height: AppSizes.m,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: const Center(
                    child: Text(AppStrings.logOut),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
