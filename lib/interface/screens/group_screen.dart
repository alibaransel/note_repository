import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:note_repository/constants/app_keys.dart';
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
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/path_service.dart';
import 'package:note_repository/services/item_service.dart';
import 'package:note_repository/services/setting_service.dart';

class GroupScreen extends StatefulWidget {
  final String groupPath;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  const GroupScreen({
    super.key,
    required this.groupPath,
    this.backgroundColor,
    this.appBar,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  static const _fabAnimationDuration = AppDurations.m;

  final ItemService _itemService = ItemService();
  final ScrollController _scrollController = ScrollController();

  late final GroupInfo _groupInfo;
  late final String _parentGroupPath;

  bool _ready = false;
  bool _isFABVisible = true;

  void _listener() {
    if (!mounted) return;
    setState(() {});
  }

  void _scrollListener() {
    if (!mounted) return;
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFABVisible) {
        setState(() {
          _isFABVisible = false;
        });
      }
    } else {
      if (!_isFABVisible) {
        setState(() {
          _isFABVisible = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _groupInfo = IdService.decodeGroupInfo(PathService().id(widget.groupPath));
    _parentGroupPath = PathService().parentGroup(widget.groupPath);

    SettingService().layoutMode.addListener(_listener);
    _itemService.addListenerAndSetup(listener: _listener, groupPath: widget.groupPath).then((_) {
      setState(() {
        _ready = true;
      });
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    SettingService().layoutMode.removeListener(_listener);
    _itemService.removeListener(_listener);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
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
            if (_ready) {
              await _itemService.deleteGroup();
              NavigationService().hide();
            }
          },
        )
      ],
    );
  }

  Widget _buildFAB() {
    return AnimatedSlide(
      duration: _fabAnimationDuration,
      curve: AppCurves.slide,
      offset: _isFABVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedSwitcher(
        duration: _fabAnimationDuration,
        child: _isFABVisible
            ? GestureDetector(
                onTap: () => NavigationService().show(NavigationRoute.addMedia),
                onLongPress: () => NavigationService().show(NavigationRoute.createGroup),
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
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: AppDurations.m,
      child: () {
        if (!_ready) return const CommonLoadingIndicator();
        if (_itemService.group.subGroupInfos.isEmpty && _itemService.group.noteInfos.isEmpty) {
          return CommonInfoBody.empty;
        }
        return _buildItemsView();
      }(),
    );
  }

  Widget _buildItemsView() {
    return GridView.builder(
      itemCount: _itemService.group.subGroupInfos.length + _itemService.group.noteInfos.length,
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
        crossAxisCount: SettingService().layoutMode.value == LayoutMode.list ? 1 : 2,
        mainAxisExtent: AppSizes.l,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index < _itemService.group.subGroupInfos.length) {
          return GroupCard(
            groupInfo: _itemService.group.subGroupInfos[index],
            parentGroupPath: widget.groupPath,
          );
        }
        return NoteCard(
          noteInfo: _itemService.group.noteInfos[index - _itemService.group.subGroupInfos.length],
          groupPath: widget.groupPath,
        );
      },
    );
  }
}
