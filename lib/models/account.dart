import 'package:flutter/material.dart';

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
}
