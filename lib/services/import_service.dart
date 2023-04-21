import 'package:file_picker/file_picker.dart';
import 'package:note_repository/models/service.dart';

class ImportService extends Service {
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg'];
  static const List<String> allowedVideoExtensions = ['mp4'];
  static const List<String> allowedAudioExtensions = [];
  static const List<String> allowedExtensions = [
    ...allowedImageExtensions,
    ...allowedVideoExtensions,
    ...allowedAudioExtensions
  ];

  static Future<List<String>> _importFiles({required bool multipleFile}) async {
    //TODO: Refactor all of this file
    //TODO: Complete Android and iOS setup
    //TODO: Improve a lot of thing
    //Catch access denied error
    //Check aspect ratio of image or video on note screen
    //Add file converting support
    //Maybe use platform specific file types
    //Add Importing status ui
    //...

    final FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: multipleFile,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (filePickerResult == null || filePickerResult.count == 0) throw '';
    return filePickerResult.paths.cast<String>();
  }

  static Future<String> importSingleFile() async => (await _importFiles(multipleFile: false)).first;

  static Future<List<String>> importMultipleFiles() => _importFiles(multipleFile: true);
}
