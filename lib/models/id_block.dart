import 'package:flutter/material.dart';
import 'package:note_repository/models/note.dart';

class IdBlock {
  Type itemType;
  String name;
  DateTime dateTime;
  Color? color;
  NoteType? noteType;

  IdBlock({
    required this.itemType,
    required this.name,
    required this.dateTime,
    this.color,
    this.noteType,
  });
}
