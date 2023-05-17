import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/services/storage_service.dart';

class Account {
  Account({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.loginType,
  });
  String uid;
  String name;
  String email;
  Image image;
  String loginType;

  Future<Account> fromJson(Map<String, dynamic> json) async {
    return Account(
      uid: json[AppKeys.uid]! as String,
      name: json[AppKeys.name]! as String,
      email: json[AppKeys.email]! as String,
      image: await StorageService.file.getImage(AppPaths.userImage), //TODO: Don't cache image here
      loginType: json[AppKeys.loginType]! as String,
    );
  }

  Map<String, dynamic> toJson() => {
        AppKeys.uid: uid,
        AppKeys.name: name,
        AppKeys.email: email,
        AppKeys.loginType: loginType,
      };
}
