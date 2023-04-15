import 'package:flutter/material.dart';
import 'package:note_repository/models/note.dart';

class Group {
  Group({
    required this.path,
    required this.info,
    required this.subGroupInfos,
    required this.noteInfos,
  });
  String path;
  GroupInfo info;
  List<GroupInfo> subGroupInfos;
  List<NoteInfo> noteInfos;
}

class GroupInfo {
  GroupInfo({
    required this.name,
    required this.dateTime,
    required this.color,
  });
  String name;
  DateTime dateTime;
  Color color;
}
