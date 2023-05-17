import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/services/navigation_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    required this.titles,
    super.key,
    this.centerTitles = true,
    this.autoAddBackButton = true,
    this.useScrolledUnderElevation = false,
    this.useCommonBackground = false,
    this.color,
    this.actions = const [],
  });
  final List<Widget> titles;
  final bool centerTitles;
  final bool autoAddBackButton;
  final bool useScrolledUnderElevation;
  final bool useCommonBackground;
  final Color? color;
  final List<Widget> actions;

  static const _appBarHeight = kToolbarHeight;

  static double heightWithStatusBar(BuildContext context) =>
      _appBarHeight + MediaQuery.of(context).viewPadding.top;

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 5,
      scrolledUnderElevation: useScrolledUnderElevation ? AppSizes.elevation : 0,
      backgroundColor: color ?? Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: useCommonBackground
          ? CommonBackground(
              borderRadius: 0,
              child: SizedBox(
                height: heightWithStatusBar(context),
                width: double.infinity,
              ),
            )
          : null,
      title: Row(
        children: [
          if (autoAddBackButton && (ModalRoute.of(context)?.impliesAppBarDismissal ?? false))
            centerTitles ? Expanded(child: Row(children: [_buildBackButton()])) : _buildBackButton()
          else
            centerTitles ? const Spacer() : const SizedBox(width: AppSizes.spacingM),
          if (centerTitles) _buildTitles() else Expanded(child: _buildTitles()),
          if (centerTitles) Expanded(child: _buildActions()) else _buildActions(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return CommonIconButton(
      size: AppSizes.buttonM,
      iconSize: AppSizes.iconM,
      icon: AppIcons.arrowBack,
      onTap: () => NavigationService().hide(),
    );
  }

  Widget _buildTitles() {
    return Row(
      children: titles,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }
}
