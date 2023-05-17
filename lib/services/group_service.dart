import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/group_notifier.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/id_service.dart';
import 'package:note_repository/services/import_service.dart';
import 'package:note_repository/services/path_service.dart';
import 'package:note_repository/services/share_service.dart';
import 'package:note_repository/services/storage_service.dart';
import 'package:note_repository/services/time_service.dart';

//TODO: Remove static methods

class GroupService extends Service with Initable {
  GroupService({
    required this.groupPath,
    this.parentGroupService,
  });

  final String groupPath;
  final GroupService? parentGroupService;

  late final GroupNotifier _group;

  ValueNotifier<Group> get group => _group;

  @override
  Future<void> init() async {
    if (isInitialized) return;
    await _initGroup();
    super.init();
  }

  Future<void> _initGroup() async {
    _group = GroupNotifier(
      Group(
        path: groupPath,
        info: _getGroupInfo(),
        subGroupInfos: await _getGroupInfos(),
        noteInfos: await _getNoteInfos(),
      ),
    );
  }

  GroupInfo _getGroupInfo() => IdService.decodeGroupInfo(PathService().id(groupPath));

  Future<List<GroupInfo>> _getGroupInfos() async {
    final Map<String, dynamic> groupIdsData =
        await StorageService.file.getData(PathService().groupGroupIds(groupPath));
    final List<String> groupIds = (groupIdsData[AppKeys.data] as List).cast();
    final List<GroupInfo> groupInfos = groupIds.map(IdService.decodeGroupInfo).toList();
    return groupInfos;
  }

  Future<List<NoteInfo>> _getNoteInfos() async {
    final Map<String, dynamic> noteIdsData =
        await StorageService.file.getData(PathService().groupNoteIds(groupPath));
    final List<String> noteIds = (noteIdsData[AppKeys.data] as List).cast();
    final List<NoteInfo> noteInfos = noteIds.map(IdService.decodeNoteInfo).toList();
    return noteInfos;
  }

  bool _isGroupNameExist(String groupName) {
    return _group.value.subGroupInfos.any((groupInfo) {
      return groupInfo.name == groupName;
    });
  }

  Future<void> createGroup(GroupInfo newGroupInfo) async {
    if (_isGroupNameExist(newGroupInfo.name)) return; //TODO: Add Name exist exception
    final Map<String, dynamic> groupIdsData =
        await StorageService.file.getData(PathService().groupGroupIds(groupPath));
    final List<String> groupIds = (groupIdsData[AppKeys.data] as List).cast()
      ..add(IdService.encodeGroupInfo(newGroupInfo));
    await StorageService.file.setData(
      path: PathService().groupGroupIds(groupPath),
      data: {
        AppKeys.data: groupIds,
      },
    );
    final String newGroupPath = PathService().group(
      parentGroupPath: groupPath,
      groupInfo: newGroupInfo,
    );
    await StorageService.directory.create(newGroupPath);
    await StorageService.file.setData(
      //TODO: Separate create and set(or update) methods for prevent confusion and improve readability of code
      path: PathService().groupGroupIds(newGroupPath),
      data: {AppKeys.data: <dynamic>[]},
    );
    await StorageService.file.setData(
      path: PathService().groupNoteIds(newGroupPath),
      data: {AppKeys.data: <dynamic>[]},
    );
    await StorageService.directory.create(PathService().groupGroups(newGroupPath));
    await StorageService.directory.create(PathService().groupNotes(newGroupPath));
    _group.addGroupInfo(newGroupInfo);
  }

  Future<void> delete() async {
    if (parentGroupService == null) return; //TODO: Add exception
    await parentGroupService!.deleteGroup(_group.value.info);
    await StorageService.directory.delete(groupPath);
  }

  //Future<void> editGroup() async {}
  Future<void> deleteGroup(GroupInfo groupInfo) async {
    final String groupIdsPath = PathService().groupGroupIds(groupPath);
    final Map<String, dynamic> groupIdsData = await StorageService.file.getData(groupIdsPath);
    final List<String> groupIds = (groupIdsData[AppKeys.data] as List).cast()
      ..remove(IdService.encodeGroupInfo(groupInfo));
    await StorageService.file.setData(
      path: groupIdsPath,
      data: {AppKeys.data: groupIds},
    );
    _group.removeGroupInfo(groupInfo);
  }

  Future<void> createNote({
    required NoteType type,
    required String realMediaPath,
    required bool deleteOriginalFile,
  }) async {
    //TODO: Improve naming (Add name exist exception when custom note names available)
    final List<int> noteNumbers = _group.value.noteInfos
        .map((groupNoteInfo) => int.parse(groupNoteInfo.name.split('_')[1]))
        .toList();
    int newNoteNumber = 0;
    if (noteNumbers.isEmpty) {
      newNoteNumber = 1;
    } else {
      noteNumbers.sort();
      if (noteNumbers.first != 1) {
        newNoteNumber = 1;
      } else if (noteNumbers.length == 1) {
        newNoteNumber = noteNumbers.first + 1;
      } else {
        for (int i = 0; i < noteNumbers.length - 1; i++) {
          if (noteNumbers[i + 1] - noteNumbers[i] > 1) {
            newNoteNumber = noteNumbers[i] + 1;
            break;
          }
        }
        if (newNoteNumber == 0) newNoteNumber = noteNumbers.last + 1;
      }
    }
    final NoteInfo noteInfo = NoteInfo(
      name: 'note_$newNoteNumber',
      dateTime: DateTime.now(),
      type: type,
    );
    final String id = IdService.encodeNoteInfo(noteInfo);
    final Map<String, dynamic> noteIdsData =
        await StorageService.file.getData(PathService().groupNoteIds(groupPath));
    final List<String> noteIds = (noteIdsData[AppKeys.data] as List).cast()..add(id);
    await StorageService.file.setData(
      path: PathService().groupNoteIds(groupPath),
      data: {
        AppKeys.data: noteIds,
      },
    );
    if (deleteOriginalFile) {
      await StorageService.file.move(
        oldPath: realMediaPath,
        newPath: PathService().noteFile(id),
      );
    } else {
      await StorageService.file.copy(
        oldPath: realMediaPath,
        newPath: PathService().noteFile(id),
      );
    }
    await StorageService.file.setData(
      path: PathService().note(groupPath: groupPath, noteInfo: noteInfo),
      data: {
        AppKeys.name: noteInfo.name,
        AppKeys.dateTime: TimeService.encode(noteInfo.dateTime),
        AppKeys.type: noteInfo.type.name,
      },
    );
    _group.addNoteInfo(noteInfo);
  }

  Future<void> createNoteWithImporting() async {
    final String filePath = await ImportService.importSingleFile();
    final String pickedFileExtension = filePath.split('.').last;
    NoteType? noteType;
    if (ImportService.allowedImageExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.image;
    } else if (ImportService.allowedVideoExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.video;
    } else if (ImportService.allowedAudioExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.audio;
    }
    if (noteType == null) throw ''; //TODO
    await createNote(
      type: noteType,
      realMediaPath: filePath,
      deleteOriginalFile: false,
    );
    //await FilePicker.platform.clearTemporaryFiles();//TODO (Note: only working on Android and iOS)
  }

  //Future<void> editNote() async {}
  //TODO: Stop using notePath as parameter
  Future<Note> getNote(String notePath) async {
    return Note(
      path: notePath,
      info: IdService.decodeNoteInfo(PathService().id(notePath)),
      file: StorageService.file.get(PathService().noteFile(PathService().id(notePath))),
    );
  }

  //TODO: Stop using notePath as parameter
  Future<void> deleteNote(String notePath) async {
    final String id = PathService().id(notePath);
    final String groupNoteIdsPath = PathService().groupNoteIds(PathService().groupOfNote(notePath));
    final Map<String, dynamic> groupNoteIdsData =
        await StorageService.file.getData(groupNoteIdsPath);
    final List<String> groupNoteIds = (groupNoteIdsData[AppKeys.data] as List).cast()..remove(id);
    await StorageService.file.setData(
      path: groupNoteIdsPath,
      data: {
        AppKeys.data: groupNoteIds,
      },
    );
    await StorageService.file.delete(notePath);
    await StorageService.file.delete(PathService().noteFile(id));
  }

  //TODO: Stop using notePath as parameter
  Future<void> shareNote(String noteFilePath) => ShareService.shareFile(noteFilePath);
}
