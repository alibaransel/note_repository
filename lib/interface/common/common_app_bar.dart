import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/services/navigation_service.dart';

class CommonAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool centerTitles;
  final bool autoAddBackButton;
  final bool useScrolledUnderElevation;
  final bool useCommonBackground;
  final Color? color;
  final List<Widget> titles;
  final List<Widget> actions;

  const CommonAppBar({
    super.key,
    this.centerTitles = true,
    this.autoAddBackButton = true,
    this.useScrolledUnderElevation = false,
    this.useCommonBackground = false,
    this.color,
    required this.titles,
    this.actions = const [],
  });

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
          autoAddBackButton && (ModalRoute.of(context)?.impliesAppBarDismissal ?? false)
              ? centerTitles
                  ? Expanded(child: Row(children: [_buildBackButton()]))
                  : _buildBackButton()
              : centerTitles
                  ? const Spacer()
                  : const SizedBox(width: AppSizes.spacingM),
          centerTitles ? _buildTitles() : Expanded(child: _buildTitles()),
          centerTitles ? Expanded(child: _buildActions()) : _buildActions(),
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
