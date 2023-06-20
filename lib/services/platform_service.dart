import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:note_repository/enums/platform_type.dart';
import 'package:note_repository/models/service.dart';

class PlatformService extends Service with Initable {
  factory PlatformService() => _instance;
  PlatformService._();
  static final PlatformService _instance = PlatformService._();

  static late final PlatformType platformType;
  static late final int numberOfProcessors; //TODO: Check 0 value case
  static late final String operatingSystemVersion;
  static late final String pathSeparator;

  @override
  void init() {
    _initPlatformInfo();
    super.init();
  }

  void _initPlatformInfo() {
    platformType = _getPlatformType();
    if (kIsWeb) {
      numberOfProcessors = 0;
      operatingSystemVersion = '';
      pathSeparator = '';
    } else {
      numberOfProcessors = Platform.numberOfProcessors;
      operatingSystemVersion = Platform.operatingSystemVersion;
      pathSeparator = Platform.pathSeparator;
    }
  }

  PlatformType _getPlatformType() {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isFuchsia) return PlatformType.fuchsia;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isLinux) return PlatformType.linux;
    if (Platform.isMacOS) return PlatformType.macos;
    //TODO: if(Platform.isWindows)
    return PlatformType.windows;
  } //TODO: Add else block logic for unsupported platform (and maybe add unsupported platform screen)
}
