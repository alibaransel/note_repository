import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/configurations/app_settings.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_physics.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_app_bar.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/interface/common/common_info_body.dart';
import 'package:note_repository/interface/common/common_loading_indicator.dart';
import 'package:note_repository/interface/common/common_text.dart';
import 'package:note_repository/interface/customs/group_card.dart';
import 'package:note_repository/interface/customs/note_card.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/services/id_service.dart';
import 'package:note_repository/services/item_service.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/path_service.dart';
import 'package:note_repository/services/setting_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    required this.groupPath,
    super.key,
    this.backgroundColor,
    this.appBar,
  });
  final String groupPath;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  static const _fabAnimationDuration = AppDurations.m;

  final ScrollController _scrollController = ScrollController();

  late final ItemService _itemService;
  late final GroupInfo _groupInfo;
  late final String _parentGroupPath;

  @override
  void initState() {
    super.initState();
    _groupInfo = IdService.decodeGroupInfo(PathService().id(widget.groupPath));
    _parentGroupPath = PathService().parentGroup(widget.groupPath);
    _itemService = ItemService(widget.groupPath);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: '${AppKeys.groupBackgroundTag}-$_parentGroupPath-${_groupInfo.name}',
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: _groupInfo.color,
          ),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
          appBar: widget.appBar ?? _buildAppBar(),
          body: _buildBody(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFAB(),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar(
      centerTitles: false,
      useCommonBackground: true,
      titles: [
        Expanded(
          child: Hero(
            tag: '${AppKeys.groupTitleTag}-$_parentGroupPath-${_groupInfo.name}',
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  const Icon(
                    AppIcons.folder,
                    size: AppSizes.iconL,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: CommonText(_groupInfo.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      actions: [
        CommonIconButton(
          size: AppSizes.buttonM,
          iconSize: AppSizes.iconM,
          icon: AppIcons.delete,
          onTap: () async {
            if (_itemService.isInitialized) {
              await _itemService.deleteGroup();
              NavigationService().hide();
            }
          },
        )
      ],
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (_, __) {
        // TODO: Don't rebuild when scroll direction not changed
        //print('Rebuilding ${DateTime.now()}');
        late final bool isFABVisible;
        if (!_scrollController.hasClients) {
          isFABVisible = true;
        } else {
          isFABVisible = _scrollController.position.userScrollDirection != ScrollDirection.reverse;
        }
        return AnimatedSlide(
          duration: _fabAnimationDuration,
          curve: AppCurves.slide,
          offset: isFABVisible ? Offset.zero : const Offset(0, 1),
          child: AnimatedSwitcher(
            duration: _fabAnimationDuration,
            child: isFABVisible
                ? GestureDetector(
                    onTap: () => NavigationService().show(AppNavigationRoutes.addMedia),
                    onLongPress: () => NavigationService().show(AppNavigationRoutes.createGroup),
                    child: const CommonBackground(
                      child: SizedBox(
                        height: AppSizes.createButton,
                        width: AppSizes.createButton,
                        child: Icon(
                          AppIcons.add,
                          size: AppSizes.iconL,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _itemService.init(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: AppDurations.m,
          child: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CommonLoadingIndicator();
            }
            if (_itemService.group.value.subGroupInfos.isEmpty &&
                _itemService.group.value.noteInfos.isEmpty) {
              return CommonInfoBody.empty;
            }
            return _buildItemsView();
          }(),
        );
      },
    );
  }

  Widget _buildItemsView() {
    return ValueListenableBuilder<LayoutMode>(
      valueListenable: SettingService().layoutMode,
      builder: (_, layoutMode, __) {
        return GridView.builder(
          padding: EdgeInsets.only(
            top: AppSizes.spacingM + CommonAppBar.heightWithStatusBar(context),
            bottom: AppSizes.spacingM,
            left: AppSizes.spacingM,
            right: AppSizes.spacingM,
          ),
          physics: AppPhysics.mainWithAlwaysScroll,
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: AppSizes.spacingM,
            crossAxisSpacing: AppSizes.spacingM,
            crossAxisCount: layoutMode == LayoutMode.list ? 1 : 2,
            mainAxisExtent: AppSizes.l,
          ),
          itemCount: _itemService.group.value.subGroupInfos.length +
              _itemService.group.value.noteInfos.length,
          itemBuilder: (BuildContext context, int index) {
            if (index < _itemService.group.value.subGroupInfos.length) {
              return GroupCard(
                groupInfo: _itemService.group.value.subGroupInfos[index],
                parentGroupPath: widget.groupPath,
              );
            }
            return NoteCard(
              noteInfo: _itemService
                  .group.value.noteInfos[index - _itemService.group.value.subGroupInfos.length],
              groupPath: widget.groupPath,
            );
          },
        );
      },
    );
  }
}
