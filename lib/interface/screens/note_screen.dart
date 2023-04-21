import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_key_maps.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_app_bar.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/interface/common/common_loading_indicator.dart';
import 'package:note_repository/interface/common/common_text.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/services/id_service.dart';
import 'package:note_repository/services/group_service.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/path_service.dart';
import 'package:note_repository/services/time_service.dart';
import 'package:note_repository/services/ui_service.dart';
import 'package:video_player/video_player.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({
    //TODO: Get Note object instead of note path
    required this.notePath,
    required this.groupService,
    super.key,
  });

  final String notePath;
  final GroupService groupService;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with WidgetsBindingObserver {
  //TODO: Optimize for performance with widget usage
  //TODO: Combine common design constants
  //TODO: Improve performance
  late final NoteInfo _noteInfo;
  late final Note _note;
  late final VideoPlayerController _videoPlayerController;
  late final Duration _videoDuration;

  bool _ready = false;
  bool _isPlaying = false;
  bool _isSoundOn = true;
  bool _isFullScreenMode = false;

  void _videoPlayerListener() {
    if (!mounted) return;
    final VideoPlayerValue videoPlayerValue = _videoPlayerController.value;
    setState(() {
      _isPlaying = videoPlayerValue.isPlaying;
      _isSoundOn = videoPlayerValue.volume == 1;
    });
  }

  Future<void> _fetch() async {
    _note = await widget.groupService.getNote(widget.notePath);
    switch (_note.info.type) {
      case NoteType.image:
        if (!mounted) return;
        await precacheImage(FileImage(_note.file), context); //TODO
        break;
      case NoteType.video:
        _videoPlayerController = VideoPlayerController.file(_note.file);
        _videoPlayerController.addListener(_videoPlayerListener);
        await _videoPlayerController.initialize();
        _videoDuration = _videoPlayerController.value.duration;
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    _noteInfo = IdService.decodeNoteInfo(PathService().id(widget.notePath));
    WidgetsBinding.instance.addObserver(this);
    _fetch().then((_) {
      if (!mounted) return;
      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        if (_isPlaying) await _videoPlayerController.pause();
        break;
      default:
    }
  }

  @override
  void dispose() {
    UIService.restoreOverlays();
    WidgetsBinding.instance.removeObserver(this);
    if (_note.info.type == NoteType.video) {
      _videoPlayerController
        ..removeListener(_videoPlayerListener)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildBackground(),
        _buildBody(),
        _buildAppBar(),
        _buildActionBox(),
      ],
    );
  }

  Widget _buildBackground() {
    return Hero(
      tag: '${AppKeys.noteBackgroundTag}-${widget.notePath}',
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.groupRed,
              AppColors.groupPurple,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: AppDurations.m,
      child: !_ready
          ? const CommonLoadingIndicator()
          : Stack(
              children: [
                Center(child: _buildItemView()),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isFullScreenMode = !_isFullScreenMode;
                    });
                    if (_isFullScreenMode) {
                      await UIService.hideOverlays();
                    } else {
                      await UIService.restoreOverlays();
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildItemView() {
    switch (_note.info.type) {
      case NoteType.image:
        return _buildImageView();
      case NoteType.video:
        return _buildVideoView();
      case NoteType.audio:
        return const SizedBox();
    }
  }

  Widget _buildImageView() {
    //TODO: Fix: After zoom don't show background while image can fill the entire screen
    //TODO: Check zoom level is same all screen variants and content ratios
    //TODO: Store min and max as constant scale on separate file
    //TODO: Zoom on double tap
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.file(_note.file),
      ),
    );
  }

  Widget _buildVideoView() {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: VideoPlayer(_videoPlayerController),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: AppDurations.m,
        curve: AppCurves.slide,
        offset: _isFullScreenMode ? const Offset(0, -2) : Offset.zero,
        child: CommonAppBar(
          centerTitles: false,
          useCommonBackground: true,
          titles: [
            Expanded(
              child: Hero(
                tag: '${AppKeys.noteTitleTag}-${widget.notePath}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Row(
                    children: [
                      Icon(
                        AppKeyMaps.noteIcon[_noteInfo.type],
                        size: AppSizes.iconL,
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: CommonText(
                          _noteInfo.name,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBox() {
    return Positioned(
      bottom: MediaQuery.of(context).viewPadding.bottom + AppSizes.spacingM,
      left: AppSizes.spacingM,
      right: AppSizes.spacingM,
      child: AnimatedSlide(
        duration: AppDurations.m,
        offset: (_ready && !_isFullScreenMode) ? Offset.zero : const Offset(0, 2),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              _buildPlayerBox(),
              const SizedBox(height: AppSizes.spacingM),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBox() {
    return AnimatedSwitcher(
      //TODO: Improve this
      duration: AppDurations.m,
      child: (_ready && _noteInfo.type != NoteType.image)
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonBackground(
                      child: Container(
                        //TODO: I can add animation to text and container
                        height: 20,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
                        child: Text(
                          TimeService.videoTime(_videoPlayerController.value.position),
                        ),
                      ),
                    ),
                    CommonBackground(
                      child: Container(
                        //TODO: I can add animation to text and container
                        height: 20,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
                        child: Text(
                          TimeService.videoTime(_videoDuration),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingS),
                CommonBackground(
                  child: Container(
                    height: 20, //TODO: Is not necessary?
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              AnimatedSlide(
                                duration: AppDurations.m,
                                offset: Offset(
                                  () {
                                    int maxDuration = 0;
                                    for (final DurationRange durationRange
                                        in _videoPlayerController.value.buffered) {
                                      final int end = durationRange.end.inMilliseconds;
                                      if (end > maxDuration) {
                                        maxDuration = end;
                                      }
                                    }
                                    return (maxDuration / _videoDuration.inMilliseconds) - 1;
                                  }(),
                                  0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white10, //TODO: Use AppColors
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              AnimatedSlide(
                                duration: AppDurations.m,
                                offset: Offset(
                                  (_videoPlayerController.value.position.inMilliseconds /
                                          _videoDuration.inMilliseconds) -
                                      1,
                                  0,
                                ),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.green, //TODO: Use AppColors
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    margin: const EdgeInsets.only(right: 2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (details) async {
                                  await _videoPlayerController.seekTo(
                                    Duration(
                                      milliseconds:
                                          ((details.localPosition.dx / constraints.maxWidth) *
                                                  _videoDuration.inMilliseconds)
                                              .round(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: AppDurations.m,
          child: _noteInfo.type == NoteType.image
              ? null
              : CommonIconButton(
                  square: true,
                  commonBackground: true,
                  size: AppSizes.buttonM,
                  iconSize: AppSizes.iconM,
                  icon: _isPlaying ? AppIcons.pause : AppIcons.play,
                  onTap: () async {
                    if (_isPlaying) {
                      await _videoPlayerController.pause();
                    } else {
                      await _videoPlayerController.play();
                    }
                  },
                ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        CommonBackground(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CommonIconButton(
                size: AppSizes.buttonM,
                iconSize: AppSizes.iconM,
                icon: AppIcons.favoriteOff,
              ),
              const CommonIconButton(
                size: AppSizes.buttonM,
                iconSize: AppSizes.iconM,
                icon: AppIcons.download,
              ),
              CommonIconButton(
                size: AppSizes.buttonM,
                iconSize: AppSizes.iconM,
                icon: AppIcons.share,
                onTap: () async {
                  await widget.groupService.shareNote(_note.file.path);
                },
              ),
              CommonIconButton(
                size: AppSizes.buttonM,
                iconSize: AppSizes.iconM,
                icon: AppIcons.delete,
                onTap: () async {
                  if (_ready) {
                    await widget.groupService.deleteNote(widget.notePath);
                    NavigationService().hide();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        AnimatedSwitcher(
          duration: AppDurations.m,
          child: _noteInfo.type == NoteType.image
              ? null
              : CommonIconButton(
                  square: true,
                  commonBackground: true,
                  size: AppSizes.buttonM,
                  iconSize: AppSizes.iconM,
                  icon: _isSoundOn ? AppIcons.soundOn : AppIcons.soundOff,
                  onTap: () async {
                    if (_isSoundOn) {
                      await _videoPlayerController.setVolume(0);
                    } else {
                      await _videoPlayerController.setVolume(1);
                    }
                  },
                ),
        ),
      ],
    );
  }
}
