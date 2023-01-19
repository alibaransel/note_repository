import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/constants/configurations/app_defaults.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/path_service.dart';

//TODO: Improve

class StorageService extends Service with Initable {
  factory StorageService() => _instance;
  static final _instance = StorageService._();
  StorageService._();

  static const directory = _DirectoryService();
  static const file = _FileService();

  @override
  Future<void> init() async {
    await PathService().init();
    final File file = const _FileService().get(AppPaths.config);
    final bool exists = await file.exists();
    if (!exists) await _createDefaults();
  }

  Future<void> _createDefaults() async {
    for (String directoryPath in AppDefaults.directoryPaths) {
      await const _DirectoryService().create(directoryPath);
    }
    AppDefaults.filePathsAndData.forEach((path, data) async {
      await const _FileService().setData(path: path, data: data);
    });
  }
}

class _DirectoryService {
  const _DirectoryService();

  Directory get(String path) {
    path = PathService().fullPath(path);
    return Directory(path);
  }

  Future<void> create(String path) async {
    final Directory directory = get(path);
    await directory.create(recursive: true);
  }

  Future<void> delete(String path) async {
    final Directory directory = get(path);
    await directory.delete(recursive: true);
  }
}

class _FileService {
  const _FileService();

  File get(String path) {
    path = PathService().fullPath(path);
    return File(path);
  }

  Future<void> setData({required String path, required Map<String, dynamic> data}) async {
    final File file = get(path);
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> updateData({required String path, required Map<String, dynamic> newData}) async {
    final Map<String, dynamic> data = await getData(path);
    newData.forEach((key, value) {
      data[key] = value;
    });
    await setData(path: path, data: data);
  }

  Future<void> emptyData(String path) async {
    setData(path: path, data: {});
  }

  Future<Map<String, dynamic>> getData(String path) async {
    final File file = get(path);
    final String jsonString = await file.readAsString();
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  Future<void> saveImage({required String path, required Uint8List dataBites}) async {
    final File file = get(path);
    await file.writeAsBytes(dataBites);
  }

  Future<Image> getImage(String path) async {
    final File imageFile = get(path);
    return Image.file(imageFile);
  }

  Future<void> delete(String path) async {
    final File file = get(path);
    await file.delete();
  }

  Future<void> copy({required String oldPath, required String newPath}) async {
    await get(oldPath).copy(PathService().fullPath(newPath));
  }

  Future<void> move({required String oldPath, required String newPath}) async {
    await copy(oldPath: oldPath, newPath: newPath);
    await File(oldPath).delete();
  }

/*
  Future<void> rename({required String path, required String newName}) async {
    //PathService().
    //getFile(path).rename(newPath)
  }
*/
}
