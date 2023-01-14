import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';
import 'package:note_repository/services/orientation_service.dart';

//TODO: Improve for race conditions
//TODO: Add error conditions
//TODO: Try multi camera preview, image and video actions, camera changing and camera mode changing

class CameraService with WidgetsBindingObserver {
  factory CameraService() => _instance;
  static final CameraService _instance = CameraService._();
  CameraService._();

  static const Offset _centerOffset = Offset(0.5, 0.5);

  final ValueNotifier<CameraStatus> _statusNotifier = ValueNotifier(CameraStatus.notFetched);

  late final List<CameraDescription> _cameras;
  late final List<int> _frontCameraIndexes;
  late final List<int> _backCameraIndexes;
  late final List<int> _externalCameraIndexes;

  Offset _focusAndExposurePoint = _centerOffset;
  int _listenerCount = 0;
  CameraMediaCallback? _mediaCallback;

  late DeviceOrientation _deviceOrientation;
  late CameraController _controller;
  late int _cameraIndex;
  late bool _focusPointSupported;
  late bool _exposurePointSupported;

  ValueNotifier<CameraStatus> get status => _statusNotifier;
  int get cameraIndex => _cameraIndex;
  List<int> get frontCameraIndexes => _frontCameraIndexes;
  List<int> get backCameraIndexes => _backCameraIndexes;
  List<int> get externalCameraIndexes => _externalCameraIndexes;
  FlashMode get flashMode => _controller.value.flashMode;
  FocusMode get focusMode => _controller.value.focusMode;
  Offset get focusAndExposurePoint => _focusAndExposurePoint;
  bool get focusOrExposurePointSupported => _focusPointSupported || _exposurePointSupported;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //TODO: Here
    switch (state) {
      case AppLifecycleState.paused:
        _stop();
        break;
      case AppLifecycleState.resumed:
        _start();
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  void _orientationListener() {
    _deviceOrientation = OrientationService().value;
  }

  void _fetchCameraIndexes() {
    List<int> frontCameraIndexesCounted = [];
    List<int> backCameraIndexesCounted = [];
    List<int> externalCameraIndexesCounted = [];
    for (int i = 0; i < _cameras.length; i++) {
      () {
        switch (_cameras[i].lensDirection) {
          case CameraLensDirection.front:
            return frontCameraIndexesCounted;
          case CameraLensDirection.back:
            return backCameraIndexesCounted;
          case CameraLensDirection.external:
            return externalCameraIndexesCounted;
        }
      }()
          .add(i);
    }
    _frontCameraIndexes = frontCameraIndexesCounted;
    _backCameraIndexes = backCameraIndexesCounted;
    _externalCameraIndexes = externalCameraIndexesCounted;
  }

  Future<void> _setDefaultModes() async {
    if (_controller.value.flashMode != AppDefaults.flashMode) {
      await _controller.setFlashMode(AppDefaults.flashMode);
    }
    if (_controller.value.focusMode != AppDefaults.focusMode) {
      await _controller.setFocusMode(AppDefaults.focusMode);
    }
    if (_controller.value.exposureMode != AppDefaults.exposureMode) {
      await _controller.setExposureMode(AppDefaults.exposureMode);
    }
    if (_focusPointSupported) {
      await _controller.setFocusPoint(_centerOffset);
    }
    if (_exposurePointSupported) {
      await _controller.setExposurePoint(_centerOffset);
    }
    _focusAndExposurePoint = _centerOffset;
  }

  Future<void> _setCamera(int cameraIndex) async {
    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.max,
    );
    await _controller.initialize();
    _cameraIndex = cameraIndex;
    _focusPointSupported = _controller.value.focusPointSupported;
    _exposurePointSupported = _controller.value.exposurePointSupported;
  }

  Future<void> fetch() async {
    if (_statusNotifier.value != CameraStatus.notFetched) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _statusNotifier.value = CameraStatus.noCamera;
      } else {
        _fetchCameraIndexes();
        _statusNotifier.value = CameraStatus.inactive;
      }
    } catch (_) {
      _statusNotifier.value = CameraStatus.error;
    }
  }

  Future<void> _start() async {
    await _setCamera((_backCameraIndexes + _frontCameraIndexes + _externalCameraIndexes).first);
    await _setDefaultModes();
    OrientationService().addListener(_orientationListener);
    _deviceOrientation = OrientationService().value;
  }

  Future<void> _stop() async {
    await _controller.dispose();
    OrientationService().removeListener(_orientationListener);
  }

  Future<void> addListener(VoidCallback listener, {CameraMediaCallback? mediaCallback}) async {
    _statusNotifier.addListener(listener);
    _listenerCount++;
    _mediaCallback ??= mediaCallback;
    if (_listenerCount > 1) return;
    try {
      _statusNotifier.value = CameraStatus.starting;
      await _start();
      _statusNotifier.value = CameraStatus.ready;
    } catch (e) {
      if (e is CameraException &&
          [
            'CameraAccessDenied',
            'CameraAccessDeniedWithoutPrompt',
            'CameraAccessRestricted',
            'AudioAccessDenied',
            'AudioAccessDeniedWithoutPrompt',
            'AudioAccessRestricted',
          ].contains(e.code)) {
        _statusNotifier.value = CameraStatus.permissionDenied;
      } else {
        _statusNotifier.value = CameraStatus.error;
      }
    }
  }

  Future<void> removeListener(VoidCallback listener, {CameraMediaCallback? mediaCallback}) async {
    if (mediaCallback != null && _mediaCallback == mediaCallback) {
      if ([
        CameraStatus.videoRecording,
        CameraStatus.videoRecordingPaused,
      ].contains(_statusNotifier.value)) {
        await stopVideoRecording();
      }
      _mediaCallback = null;
    }
    _statusNotifier.removeListener(listener);
    _listenerCount--;
    if (_listenerCount != 0) return;
    if (![CameraStatus.ready, CameraStatus.starting].contains(_statusNotifier.value)) return;
    await _stop();
    _statusNotifier.value = CameraStatus.inactive;
  }

  Widget preview() {
    if (!_controller.value.isInitialized) return const SizedBox();
    return _controller.buildPreview();
  }

  Future<void> takeImage() async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    _statusNotifier.value = CameraStatus.mediaProcessing;
    await _controller.lockCaptureOrientation(_deviceOrientation);
    final XFile imageXFile = await _controller.takePicture();
    await _controller.unlockCaptureOrientation();
    await _mediaCallback?.call(
      mediaType: CameraMediaType.image,
      mediaFileFullPath: imageXFile.path,
    );
    _statusNotifier.value = CameraStatus.ready;
  }

  Future<void> startVideoRecording() async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    _statusNotifier.value = CameraStatus.videoRecording;
    await _controller.lockCaptureOrientation(_deviceOrientation);
    await _controller.prepareForVideoRecording();
    await _controller.startVideoRecording();
  }

  Future<void> pauseVideoRecording() async {
    if (_statusNotifier.value != CameraStatus.videoRecording) return;
    _statusNotifier.value = CameraStatus.videoRecordingPaused;
    await _controller.pauseVideoRecording();
  }

  Future<void> resumeVideoRecording() async {
    if (_statusNotifier.value != CameraStatus.videoRecordingPaused) return;
    _statusNotifier.value = CameraStatus.videoRecording;
    await _controller.resumeVideoRecording();
  }

  Future<void> stopVideoRecording() async {
    if (![CameraStatus.videoRecording, CameraStatus.videoRecordingPaused]
        .contains(_statusNotifier.value)) {
      return;
    }
    _statusNotifier.value = CameraStatus.mediaProcessing;
    final XFile videoXFile = await _controller.stopVideoRecording();
    await _controller.unlockCaptureOrientation();
    await _mediaCallback?.call(
      mediaType: CameraMediaType.video,
      mediaFileFullPath: videoXFile.path,
    );
    _statusNotifier.value = CameraStatus.ready;
  }

  Future<void> changeCamera(int newCameraIndex) async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    if (_cameraIndex == newCameraIndex) return;
    _statusNotifier.value = CameraStatus.cameraChanging;
    await _controller.dispose();
    await _setCamera(newCameraIndex);
    await _setDefaultModes();
    _statusNotifier.value = CameraStatus.ready;
  }

  Future<void> setFlashMode(FlashMode newFlashMode) async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    if (flashMode == newFlashMode) return;
    _statusNotifier.value = CameraStatus.modeChanging;
    await _controller.setFlashMode(newFlashMode);
    _statusNotifier.value = CameraStatus.ready;
  }

  Future<void> setFocusAndExposurePoint(Offset pointOffset) async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    if (!focusOrExposurePointSupported) return;
    if (focusMode == FocusMode.locked && pointOffset == _focusAndExposurePoint) return;
    if (pointOffset.dx < 0 || pointOffset.dy < 0 || pointOffset.dx > 1 || pointOffset.dy > 1) {
      return;
    }
    _statusNotifier.value = CameraStatus.modeChanging;
    if (_focusPointSupported) {
      await _controller.setFocusMode(FocusMode.locked);
      await _controller.setFocusPoint(pointOffset);
    }
    if (_exposurePointSupported) {
      await _controller.setExposurePoint(pointOffset);
    }
    _focusAndExposurePoint = pointOffset;
    _statusNotifier.value = CameraStatus.ready;
  }

  Future<void> setAutoFocusAndExposure() async {
    if (_statusNotifier.value != CameraStatus.ready) return;
    if (!focusOrExposurePointSupported) return;
    _statusNotifier.value = CameraStatus.modeChanging;
    await _controller.setFocusMode(FocusMode.auto);
    await _controller.setExposureMode(ExposureMode.auto);
    if (_focusPointSupported) {
      await _controller.setFocusPoint(_centerOffset);
    }
    if (_exposurePointSupported) {
      await _controller.setExposurePoint(_centerOffset);
    }
    _focusAndExposurePoint = _centerOffset;
    _statusNotifier.value = CameraStatus.ready;
  }
}

enum CameraStatus {
  notFetched,
  noCamera,
  error,
  inactive,
  starting,
  permissionDenied,
  ready,
  cameraChanging,
  modeChanging,
  videoRecording,
  videoRecordingPaused,
  mediaProcessing,
}

enum CameraMediaType {
  image,
  video,
}

typedef CameraMediaCallback = FutureOr<void> Function(
    {required CameraMediaType mediaType, required String mediaFileFullPath});
