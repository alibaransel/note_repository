import 'dart:io';
import 'package:http/http.dart';
import 'package:note_repository/services/storage_service.dart';

class NetworkService {
  static const List<String> _checkURLs = [
    'google.com',
    'example.com',
  ];

  Future<bool> hasInternet() async {
    try {
      bool internetStatus = false;
      List<InternetAddress> result = [];
      for (String checkURL in _checkURLs) {
        result = await InternetAddress.lookup(checkURL);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          internetStatus = true;
          break;
        }
      }
      return internetStatus;
    } on SocketException catch (_) {
      //TODO: Remove 'catch (_)' ?!
      return false;
    }
  }

  Future<void> saveImageFromURL({required String path, required String imageURL}) async {
    Response response = await get(Uri.parse(imageURL));
    await StorageService.file.saveImage(
      path: path,
      dataBites: response.bodyBytes,
    );
  }
}
