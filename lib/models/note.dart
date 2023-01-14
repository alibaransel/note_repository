import 'dart:io';

class Note {
  String path;
  NoteInfo info;
  File file;

  Note({
    required this.path,
    required this.info,
    required this.file,
  });
}

class NoteInfo {
  String name;
  DateTime dateTime;
  NoteType type;

  NoteInfo({
    required this.name,
    required this.dateTime,
    required this.type,
  });
}

enum NoteType {
  image,
  video,
  audio,
}
