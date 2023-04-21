import 'package:note_repository/models/service.dart';
import 'package:share_plus/share_plus.dart';

class ShareService extends Service {
  static Future<void> shareFile(String filePath) async {
    //TODO: Change note file naming system or rename file before sharing
    await Share.shareXFiles([XFile(filePath)]);
  }
}
