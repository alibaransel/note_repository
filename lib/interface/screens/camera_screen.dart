import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/constants/design/app_themes.dart';
import 'package:note_repository/interface/common/common_background.dart';
import 'package:note_repository/interface/common/common_icon_button.dart';
import 'package:note_repository/interface/common/common_info_body.dart';
import 'package:note_repository/interface/common/common_loading_indicator.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/services/camera_service.dart';
import 'package:note_repository/services/group_service.dart';
import 'package:note_repository/services/navigation_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
    this._groupService, {
    super.key,
  });

  final GroupService _groupService;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  static const double _shutterSize = AppSizes.xL;
  static const double _shutterIconSizeOnReady = AppSizes.iconXL;
  static const double _shutterBorderWidthOnReady = AppSizes.borderWidthL;
  static const double _shutterIconSizeOnVideoRecording = AppSizes.iconM;
  static const double _shutterBorderWidthOnVideoRecording = AppSizes.borderWidthM;
  static const double _focusAndExposurePointSignSize = AppSizes.m;

  static final ThemeData _theme = AppThemes.dark;

  static const Duration _animatedSwitcherDuration = AppDurations.m;
  static const Duration _animatedPositionedDuration = AppDurations.m;
  static const Duration _cameraSettingBoxChangeDuration = AppDurations.m;

  static const Curve _shutterButtonsScaleAnimationCurve = AppCurves.scale;
  static const Duration _shutterButtonsScaleAnimationDuration = AppDurations.m;

  CameraStatus _status = CameraService().status.value;
  CameraSetting<dynamic>? _cameraSetting;
  bool _isVideoMode = false; //TODO: Improve this

  late int _cameraIndex;
  late FlashMode _flashMode;
  late FocusMode _focusMode;
  late Offset _focusAndExposurePoint;

  void _cameraListener() {
    if (!mounted) return;
    setState(() {
      _status = CameraService().status.value;
      if (_status == CameraStatus.ready) {
        _cameraIndex = CameraService().cameraIndex;
        _flashMode = CameraService().flashMode;
        _focusAndExposurePoint = CameraService().focusAndExposurePoint;
        _focusMode = CameraService().focusMode;
      }
      _isVideoMode = [
        CameraStatus.videoRecording,
        CameraStatus.videoRecordingPaused,
      ].contains(_status);
    });
  }

  Future<void> _mediaProcess({
    required CameraMediaType mediaType,
    required String mediaFileFullPath,
  }) async {
    await widget._groupService.createNote(
      type: mediaType == CameraMediaType.image ? NoteType.image : NoteType.video,
      realMediaPath: mediaFileFullPath,
      deleteOriginalFile: true,
    );
    NavigationService().hide();
    //TODO
    /*
    if (response == AppKeys.error) {
      NavigationService().showSnackBar(AppExceptionMessages.error);
    }
    */
  }

  Future<void> _import() async {
    await widget._groupService.createNoteWithImporting();
    NavigationService().hide();
    //TODO
    //NavigationService().showSnackBar(InfoMessage(result));
  }

  Future<void> _changeCameraSettingBox(CameraSetting<dynamic> newCameraSetting) async {
    setState(() {
      _cameraSetting = null;
    });
    if (_cameraSetting != newCameraSetting) {
      await Future<void>.delayed(_cameraSettingBoxChangeDuration);
      setState(() {
        _cameraSetting = newCameraSetting;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CameraService().addListener(
      _cameraListener,
      mediaCallback: _mediaProcess,
    );
  }

  /*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        _statusOnAppPause = _status;
        await CameraService().removeListener(_cameraListener, mediaCallback: _mediaProcess);
        break;
      case AppLifecycleState.resumed:
        if (_statusOnAppPause == null) return;
        await CameraService().addListener(_cameraListener, mediaCallback: _mediaProcess);
        if ([
          CameraStatus.videoRecording,
          CameraStatus.videoRecordingPaused,
          CameraStatus.mediaProcessing,
        ].contains(_statusOnAppPause)) {
          const NavigationService().hide();
        }
        _statusOnAppPause = null;
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }
  */

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CameraService().removeListener(_cameraListener, mediaCallback: _mediaProcess);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _theme.appBarTheme.systemOverlayStyle!,
        child: Scaffold(
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildMainBody(),
                  _buildFocusAndExposurePointSign(constraints),
                  _buildGestureLayer(constraints),
                  _buildCloseButton(),
                  _buildImportButton(),
                  _buildShutterButtons(),
                  _buildCameraSettingButtons(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    return AnimatedSwitcher(
      duration: _animatedSwitcherDuration,
      child: () {
        switch (_status) {
          case CameraStatus.notFetched:
          case CameraStatus.error:
            return CommonInfoBody.error;
          case CameraStatus.permissionDenied:
            return CommonInfoBody.permissionDenied;
          case CameraStatus.noCamera:
            return CommonInfoBody.noCamera;
          case CameraStatus.inactive:
          case CameraStatus.starting:
          case CameraStatus.mediaProcessing:
            return const CommonLoadingIndicator();
          case CameraStatus.ready:
          case CameraStatus.modeChanging:
          case CameraStatus.videoRecording:
          case CameraStatus.videoRecordingPaused:
            return _buildCameraPreview();
          case CameraStatus.cameraChanging:
            return null;
        }
      }(),
    );
  }

  Widget _buildGestureLayer(BoxConstraints constraints) {
    if (_status != CameraStatus.ready) return const SizedBox();
    return GestureDetector(
      onTapDown: (details) async {
        _cameraSetting = null;
        final Offset pointOffset = Offset(
          details.localPosition.dx / constraints.maxWidth,
          details.localPosition.dy / constraints.maxHeight,
        );
        await CameraService().setFocusAndExposurePoint(pointOffset);
      },
    );
  }

  Widget _buildFocusAndExposurePointSign(BoxConstraints constraints) {
    if (![
      CameraStatus.ready,
      CameraStatus.modeChanging,
    ].contains(_status)) return const SizedBox();
    return AnimatedPositioned(
      duration: _animatedPositionedDuration,
      top: (_focusAndExposurePoint.dy * constraints.maxHeight) -
          (_focusAndExposurePointSignSize / 2),
      left:
          (_focusAndExposurePoint.dx * constraints.maxWidth) - (_focusAndExposurePointSignSize / 2),
      child: AnimatedSwitcher(
        duration: _animatedSwitcherDuration,
        child: CameraService().focusOrExposurePointSupported && _focusMode == FocusMode.locked
            ? Container(
                height: _focusAndExposurePointSignSize,
                width: _focusAndExposurePointSignSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(
                    color: AppColors.white,
                    width: AppSizes.borderWidthXS,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: CameraService().preview(),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: AppSizes.spacingM,
      right: AppSizes.spacingM,
      child: CommonIconButton(
        autoTurn: true,
        commonBackground: true,
        size: AppSizes.buttonM,
        iconSize: AppSizes.iconM,
        icon: AppIcons.close,
        onTap: () => NavigationService().hide(),
      ),
    );
  }

  Widget _buildImportButton() {
    return Positioned(
      bottom: AppSizes.spacingM,
      right: AppSizes.spacingM,
      child: AnimatedSwitcher(
        duration: _animatedSwitcherDuration,
        child: ![
          CameraStatus.cameraChanging,
          CameraStatus.videoRecording,
          CameraStatus.videoRecordingPaused,
          CameraStatus.mediaProcessing,
        ].contains(_status)
            ? CommonIconButton(
                size: AppSizes.buttonL,
                iconSize: AppSizes.iconM,
                icon: AppIcons.import,
                square: true,
                autoTurn: true,
                commonBackground: true,
                text: AppStrings.import,
                onTap: _import,
              )
            : null,
      ),
    );
  }

  Widget _buildShutterButtons() {
    return Positioned(
      bottom: AppSizes.spacingM,
      child: AnimatedSwitcher(
        duration: _animatedSwitcherDuration,
        child: [
          CameraStatus.ready,
          CameraStatus.modeChanging,
          CameraStatus.videoRecording,
          CameraStatus.videoRecordingPaused,
        ].contains(_status)
            ? Row(
                children: [
                  _buildPauseButton(),
                  const SizedBox(width: AppSizes.spacingM),
                  _buildShutterButton(),
                  const SizedBox(width: AppSizes.spacingM),
                  _buildMarkButton(),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: () async {
        switch (_status) {
          case CameraStatus.ready:
            await CameraService().takeImage();
            break;
          case CameraStatus.videoRecording:
          case CameraStatus.videoRecordingPaused:
            await CameraService().stopVideoRecording();
            break;
          default:
        }
      },
      onLongPress: () async {
        if (_status == CameraStatus.ready) {
          await CameraService().startVideoRecording();
        }
      },
      child: AnimatedContainer(
        duration: _shutterButtonsScaleAnimationDuration,
        height: _shutterSize,
        width: _shutterSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondaryColor,
            width: _isVideoMode ? _shutterBorderWidthOnVideoRecording : _shutterBorderWidthOnReady,
          ),
          shape: BoxShape.circle,
        ),
        child: AnimatedContainer(
          duration: _shutterButtonsScaleAnimationDuration,
          height: _isVideoMode ? _shutterIconSizeOnVideoRecording : _shutterIconSizeOnReady,
          width: _isVideoMode ? _shutterIconSizeOnVideoRecording : _shutterIconSizeOnReady,
          decoration: BoxDecoration(
            color: AppColors.mainColor,
            shape: _isVideoMode ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return AnimatedScale(
      duration: _shutterButtonsScaleAnimationDuration,
      curve: _shutterButtonsScaleAnimationCurve,
      scale: _isVideoMode ? 1 : 0,
      child: CommonIconButton(
        autoTurn: true,
        size: AppSizes.buttonM,
        iconSize: AppSizes.iconM,
        icon: _status == CameraStatus.videoRecording ? AppIcons.pause : AppIcons.play,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(AppColors.backgroundOpacityM),
        onTap: () async {
          switch (_status) {
            case CameraStatus.videoRecording:
              await CameraService().pauseVideoRecording();
              break;
            case CameraStatus.videoRecordingPaused:
              await CameraService().resumeVideoRecording();
              break;
            default:
          }
        },
      ),
    );
  }

  Widget _buildMarkButton() {
    return AnimatedScale(
      duration: _shutterButtonsScaleAnimationDuration,
      curve: _shutterButtonsScaleAnimationCurve,
      scale: _isVideoMode ? 1 : 0,
      child: CommonIconButton(
        autoTurn: true,
        size: AppSizes.buttonM,
        iconSize: AppSizes.iconM,
        icon: AppIcons.mark,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(AppColors.backgroundOpacityM),
      ),
    );
  }

  Widget _buildCameraSettingButtons() {
    return Positioned(
      top: AppSizes.spacingM,
      left: AppSizes.spacingM,
      bottom: AppSizes.spacingM,
      child: AnimatedSwitcher(
        duration: _animatedSwitcherDuration,
        child: [
          CameraStatus.ready,
          CameraStatus.modeChanging,
        ].contains(_status)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingOptionButtons(),
                  const Spacer(),
                  _buildAutoFocusAndExposureButton(),
                  const SizedBox(height: AppSizes.spacingM),
                  _buildFlashButton(),
                  const SizedBox(height: AppSizes.spacingM),
                  _buildCameraSwitchButton(),
                ],
              )
            : null,
      ),
    );
  }

  AnimatedSlide _buildSettingOptionButtons() {
    return AnimatedSlide(
      offset: _cameraSetting == null ? const Offset(-2, 0) : Offset.zero,
      duration: _cameraSettingBoxChangeDuration,
      child: AnimatedSwitcher(
        duration: _cameraSettingBoxChangeDuration,
        child: _cameraSetting == null
            ? null
            : CommonBackground(
                child: Column(
                  children:
                      //TODO: find correct way
                      List.generate(
                    _cameraSetting!.options.length,
                    (i) => CommonIconButton(
                      autoTurn: true,
                      size: AppSizes.buttonS,
                      iconSize: AppSizes.iconS,
                      icon: _cameraSetting!.options[i].icon,
                      text: _cameraSetting!.options[i].text,
                      foregroundColor:
                          [_cameraIndex, _flashMode].contains(_cameraSetting!.options[i].data)
                              ? Colors.orange
                              : null,
                      onTap: () async {
                        if (_cameraSetting == null) return;
                        await _cameraSetting!.change(i);
                        setState(() {
                          _cameraSetting = null;
                        });
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAutoFocusAndExposureButton() {
    return AnimatedSwitcher(
      duration: _animatedSwitcherDuration,
      child: _focusMode == FocusMode.locked
          ? CommonIconButton(
              autoTurn: true,
              commonBackground: true,
              size: AppSizes.buttonS,
              iconSize: AppSizes.iconS,
              icon: AppIcons.focus,
              onTap: () async {
                await CameraService().setAutoFocusAndExposure();
              },
            )
          : null,
    );
  }

  Widget _buildFlashButton() {
    return CommonIconButton(
      autoTurn: true,
      commonBackground: true,
      size: AppSizes.buttonS,
      iconSize: AppSizes.iconS,
      //TODO: Crete FlashMode-AppIcon map or use for loop, choose the correct one
      icon: CameraSetting.flashMode.options
          .singleWhere((settingOption) => settingOption.data == _flashMode)
          .icon,
      onTap: () async {
        await _changeCameraSettingBox(CameraSetting.flashMode);
      },
    );
  }

  Widget _buildCameraSwitchButton() {
    final cameraSwitchCameraOption = _generateCameraSwitchOptions()
        .singleWhere((cameraSettingOption) => cameraSettingOption.data == _cameraIndex);

    return CommonIconButton(
      autoTurn: true,
      commonBackground: true,
      size: AppSizes.buttonS,
      iconSize: AppSizes.iconS,
      icon: cameraSwitchCameraOption.icon,
      text: cameraSwitchCameraOption.text,
      onTap: () async {
        await _changeCameraSettingBox(CameraSetting.cameraSwitch);
      },
    );
  }
}

//TODO: Use Setting class
class CameraSetting<DataType> {
  CameraSetting({
    required this.changeFunction,
    required this.options,
  });
  final Future<void> Function(DataType data) changeFunction;
  final List<CameraSettingOption<DataType>> options;

  Future<void> change(int optionIndex) async {
    await changeFunction(options[optionIndex].data);
  }

  static final cameraSwitch = CameraSetting<int>(
    changeFunction: CameraService().changeCamera,
    options: _generateCameraSwitchOptions(),
  );

  static final flashMode = CameraSetting<FlashMode>(
    changeFunction: CameraService().setFlashMode,
    options: const [
      CameraSettingOption<FlashMode>(data: FlashMode.off, icon: AppIcons.flashOff),
      CameraSettingOption<FlashMode>(data: FlashMode.auto, icon: AppIcons.flashAuto),
      CameraSettingOption<FlashMode>(data: FlashMode.always, icon: AppIcons.flashAlways),
      CameraSettingOption<FlashMode>(data: FlashMode.torch, icon: AppIcons.flashTorch),
    ],
  );
}

class CameraSettingOption<DataType> {
  const CameraSettingOption({
    required this.data,
    required this.icon,
    this.text,
  });
  final DataType data;
  final IconData icon;
  final String? text;
}

List<CameraSettingOption<int>> _generateCameraSwitchOptions() {
  final List<CameraSettingOption<int>> options = [];
  List<int> cameraIndexes;
  bool needText;

  cameraIndexes = CameraService().frontCameraIndexes;
  needText = cameraIndexes.length > 1;
  List.generate(cameraIndexes.length, (i) {
    options.add(
      CameraSettingOption<int>(
        data: cameraIndexes[i],
        icon: AppIcons.cameraFront,
        text: needText ? '${i + 1}' : null,
      ),
    );
  });
  cameraIndexes = CameraService().backCameraIndexes;
  needText = cameraIndexes.length > 1;
  List.generate(cameraIndexes.length, (i) {
    options.add(
      CameraSettingOption<int>(
        data: cameraIndexes[i],
        icon: AppIcons.cameraBack,
        text: needText ? '${i + 1}' : null,
      ),
    );
  });
  cameraIndexes = CameraService().externalCameraIndexes;
  needText = cameraIndexes.length > 1;
  List.generate(cameraIndexes.length, (i) {
    options.add(
      CameraSettingOption<int>(
        data: cameraIndexes[i],
        icon: AppIcons.cameraExternal,
        text: needText ? '${i + 1}' : null,
      ),
    );
  });
  return options;
}
