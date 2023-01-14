import 'package:flutter/material.dart';
import 'package:note_repository/models/note.dart';

class Group {
  String path;
  GroupInfo info;
  List<GroupInfo> subGroupInfos;
  List<NoteInfo> noteInfos;

  Group({
    required this.path,
    required this.info,
    required this.subGroupInfos,
    required this.noteInfos,
  });
}

class GroupInfo {
  String name;
  DateTime dateTime;
  Color color;

  GroupInfo({
    required this.name,
    required this.dateTime,
    required this.color,
  });
}
