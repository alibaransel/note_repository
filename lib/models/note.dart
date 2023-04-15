import 'dart:io';

class Note {
  Note({
    required this.path,
    required this.info,
    required this.file,
  });
  String path;
  NoteInfo info;
  File file;
}

class NoteInfo {
  NoteInfo({
    required this.name,
    required this.dateTime,
    required this.type,
  });
  String name;
  DateTime dateTime;
  NoteType type;
}

enum NoteType {
  image,
  video,
  audio,
}
