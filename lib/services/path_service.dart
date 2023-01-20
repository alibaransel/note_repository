import 'dart:io';
import 'package:note_repository/constants/app_key_maps.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/id_service.dart';
import 'package:path_provider/path_provider.dart';

class PathService extends Service with Initable {
  factory PathService() => _instance;
  static final PathService _instance = PathService._();
  PathService._();

  late final String _corePath;

  @override
  Future<void> init() async {
    if (isInitialized) return;
    final Directory directory = await getApplicationDocumentsDirectory();
    _corePath = directory.path;
    super.init();
  }

  String fullPath(String path) {
    if (path.startsWith(AppPaths.pathIdentifier)) {
      path = path.substring(AppPaths.pathIdentifier.length);
      path = _corePath + path;
    }
    return path;
  }

  String groupGroupIds(String groupPath) => '$groupPath${AppPaths.groupIds}';

  String groupNoteIds(String groupPath) => '$groupPath${AppPaths.noteIds}';

  String groupGroups(String parentGroupPath) => '$parentGroupPath${AppPaths.groups}';

  String groupNotes(String groupPath) => '$groupPath${AppPaths.notes}';

  String id(String path) {
    if (path.endsWith(AppPaths.dataFileExtension)) {
      path = path.substring(0, path.length - AppPaths.dataFileExtension.length);
    }
    return path.split(AppPaths.directorySeparator).last;
  }

  String parentGroup(String path) {
    return path.substring(
      0,
      path.length - (AppPaths.groups.length + AppPaths.directorySeparator.length + id(path).length),
    );
  }

  String group({required String parentGroupPath, required GroupInfo groupInfo}) {
    final String groupId = IdService.encodeGroupInfo(groupInfo);
    return '$parentGroupPath${AppPaths.groups}/$groupId';
  }

  String note({required String groupPath, required NoteInfo noteInfo}) {
    final String noteId = IdService.encodeNoteInfo(noteInfo);
    return '$groupPath${AppPaths.notes}/$noteId${AppPaths.dataFileExtension}';
  }

  String noteFile(String id) {
    final NoteType noteType = IdService.decodeNoteInfo(id).type;
    final String noteTypePath = AppKeyMaps.noteTypePath[noteType]!;
    final String noteTypeFileExtension = AppKeyMaps.noteTypeFileExtension[noteType]!;
    return '$noteTypePath/$id$noteTypeFileExtension';
  }

  String groupOfNote(String notePath) {
    return notePath.substring(
      0,
      notePath.length -
          (AppPaths.notes.length +
              AppPaths.directorySeparator.length +
              id(notePath).length +
              AppPaths.dataFileExtension.length),
    );
  }
}
