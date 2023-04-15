import 'dart:io';
import 'package:http/http.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/storage_service.dart';

class NetworkService extends Service {
  NetworkService._();

  static const List<String> _checkURLs = [
    'google.com',
    'example.com',
  ];

  static Future<bool> hasInternet() async {
    try {
      bool internetStatus = false;
      List<InternetAddress> result = [];
      for (final String checkURL in _checkURLs) {
        result = await InternetAddress.lookup(checkURL);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          internetStatus = true;
          break;
        }
      }
      return internetStatus;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> saveImageFromURL({required String path, required String imageURL}) async {
    final Response response = await get(Uri.parse(imageURL));
    await StorageService.file.saveImage(
      path: path,
      dataBites: response.bodyBytes,
    );
  }
}
