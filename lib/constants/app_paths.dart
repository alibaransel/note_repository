import 'package:note_repository/constants/app_keys.dart';

class AppPaths {
  const AppPaths._();

  static const String directorySeparator = '/';

  static const String dataFileExtension = '.json';
  static const String imageFileExtension = '.png';
  static const String videoFileExtension = '.mp4';
  static const String audioFileExtension = '.mp3';

  static const String pathIdentifier = 'path:';

  static const String core = '$pathIdentifier/core';

  //TODO: Add account path for different accounts

  static const String app = '$core/app';
  static const String config = '$app/configs$dataFileExtension';
  static const String settings = '$app/settings$dataFileExtension';
  static const String account = '$app/account$dataFileExtension';
  static const String files = '$app/files';
  static const String userImage = '$files/user-image$imageFileExtension';

  static const String user = '$core/user';

  static const String noteFiles = '$user/note-files';
  static const String images = '$noteFiles/images';
  static const String videos = '$noteFiles/videos';
  static const String audios = '$noteFiles/audios';

  static const String mainGroup = '$user/${AppKeys.mainGroupId}';

  static const String groupIds = '/group-ids$dataFileExtension';
  static const String noteIds = '/note-ids$dataFileExtension';
  static const String groups = '/groups';
  static const String notes = '/notes';
}
