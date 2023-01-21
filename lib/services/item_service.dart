import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_id_codes.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/services/id_service.dart';
import 'package:note_repository/services/path_service.dart';
import 'package:note_repository/services/storage_service.dart';
import 'package:note_repository/services/time_service.dart';
import 'package:share_plus/share_plus.dart';

class ItemService with ChangeNotifier {
  static final Map<String, ItemService> _itemPathServiceMap = {};
  static ItemService get lastItemService => _itemPathServiceMap.values.last;

  late Group _group;

  Future<void> addListenerAndSetup(
      {required VoidCallback listener, required String groupPath}) async {
    addListener(listener);
    _itemPathServiceMap[groupPath] = this;
    _group = await const _GroupService._().getGroup(groupPath);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _itemPathServiceMap.remove(_group.path);
  }

  Group get group => _group;

  bool _isNameExist({required String name, required List<dynamic> ids}) {
    for (dynamic id in ids) {
      if (id.endsWith(AppIdCodes.idCodeSeparator + name)) return true;
    }
    return false;
  }

  Future<String> tryCreateGroup(GroupInfo newGroupInfo) async {
    final String response = await const _GroupService._()
        .tryCreate(newGroupInfo: newGroupInfo, parentGroupPath: _group.path);
    if (response == AppKeys.done) {
      _group.subGroupInfos.add(newGroupInfo);
      notifyListeners();
    }
    return response;
  }

  Future<void> deleteGroup() async {
    await const _GroupService._().delete(_group.path);
    _itemPathServiceMap[PathService().parentGroup(_group.path)]!
        ._deleteSubGroup(PathService().id(_group.path));
    notifyListeners();
  }

  void _deleteSubGroup(String id) {
    final GroupInfo groupInfo = IdService.decodeGroupInfo(id);
    _group.subGroupInfos.removeWhere((element) => element.name == groupInfo.name);
    notifyListeners();
  }

  Future<String> tryCreateNote({required NoteType type, required String realMediaPath}) async {
    final NoteInfo noteInfo = await const _NoteService._().tryCreateNoteInfo(
      groupPath: _group.path,
      type: type,
    );
    final String response = await const _NoteService._().tryCreate(
      groupPath: _group.path,
      realMediaPath: realMediaPath,
      noteInfo: noteInfo,
    );
    if (response == AppKeys.done) {
      _group.noteInfos.add(noteInfo);
      notifyListeners();
    }
    return response;
  }

  Future<Note> getNote(String notePath) async => const _NoteService._().get(notePath);

  Future<void> deleteNote(String notePath) async {
    await const _NoteService._().deleteNote(notePath);
    final String name = IdService.decodeNoteInfo(PathService().id(notePath)).name;
    _group.noteInfos.removeWhere(
      (element) => element.name == name,
    );
    notifyListeners();
  }

  Future<void> shareNote(String notePath) async {
    //TODO: Change note file naming system or rename file before sharing
    await Share.shareXFiles([XFile(notePath)]);
  }

  Future<String> tryCreateNoteWithImporting() async {
    //TODO: Refactor all of this file
    //TODO: Complete Android and iOS setup
    //TODO: Improve a lot of thing
    //Catch access denied error
    //Check aspect ratio of image or video on note screen
    //Add file converting support
    //Maybe use platform specific file types
    //...
    const List<String> allowedImageExtensions = ['jpg', 'jpeg'];
    const List<String> allowedVideoExtensions = ['mp4'];
    const List<String> allowedAudioExtensions = [];
    const List<String> allowedExtensions = [
      ...allowedImageExtensions,
      ...allowedVideoExtensions,
      ...allowedAudioExtensions
    ];

    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    final String? pickedFilePath = filePickerResult?.files.first.path;
    if (pickedFilePath == null) return 'cancel';
    final String pickedFileExtension = pickedFilePath.split('.').last;
    NoteType? noteType;
    if (allowedImageExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.image;
    } else if (allowedVideoExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.video;
    } else if (allowedAudioExtensions.contains(pickedFileExtension)) {
      noteType = NoteType.audio;
    }
    if (noteType == null) throw '';
    String result = await tryCreateNote(type: noteType, realMediaPath: pickedFilePath);
    await FilePicker.platform.clearTemporaryFiles();
    return result;
  }
}

class _GroupService {
  const _GroupService._();

  Future<List<GroupInfo>> getSubGroupInfos(String groupPath) async {
    List<GroupInfo> groupInfos = [];
    final Map<String, dynamic> groupIdsData =
        await StorageService.file.getData(PathService().groupGroupIds(groupPath));
    final List<dynamic> groupIds = groupIdsData[AppKeys.data] ?? [];
    for (String groupId in groupIds) {
      groupInfos.add(IdService.decodeGroupInfo(groupId));
    }
    return groupInfos;
  }

  Future<String> tryCreate(
      {required GroupInfo newGroupInfo, required String parentGroupPath}) async {
    try {
      final Map<String, dynamic> groupIdsData =
          await StorageService.file.getData(PathService().groupGroupIds(parentGroupPath));
      List<dynamic> groupIds = groupIdsData[AppKeys.data] ?? [];
      if (ItemService()._isNameExist(name: newGroupInfo.name, ids: groupIds)) {
        return AppKeys.nameExist;
      }
      groupIds.add(IdService.encodeGroupInfo(newGroupInfo));
      await StorageService.file.setData(
        path: PathService().groupGroupIds(parentGroupPath),
        data: {
          AppKeys.data: groupIds,
        },
      );
      final String newGroupPath = PathService().group(
        parentGroupPath: parentGroupPath,
        groupInfo: newGroupInfo,
      );
      await StorageService.directory.create(newGroupPath);
      await StorageService.file.setData(
        //TODO: Separate create and set(or update) methods for prevent confusion and improve readability of code
        path: PathService().groupGroupIds(newGroupPath),
        data: {AppKeys.data: []},
      );
      await StorageService.file.setData(
        path: PathService().groupNoteIds(newGroupPath),
        data: {AppKeys.data: []},
      );
      await StorageService.directory.create(PathService().groupGroups(newGroupPath));
      await StorageService.directory.create(PathService().groupNotes(newGroupPath));
      return AppKeys.done;
    } catch (_) {
      return AppKeys.error;
    }
  }

  Future<Group> getGroup(String groupPath) async {
    return Group(
      path: groupPath,
      info: IdService.decodeGroupInfo(PathService().id(groupPath)),
      subGroupInfos: await getSubGroupInfos(groupPath),
      noteInfos: await const _NoteService._().getNoteInfos(groupPath),
    );
  }

  Future<void> delete(String groupPath) async {
    final String groupId = PathService().id(groupPath);
    final String parentGroupPath = PathService().parentGroup(groupPath);
    final String parentGroupGroupIdsPath = PathService().groupGroupIds(parentGroupPath);
    final Map<String, dynamic> parentGroupGroupIdsData =
        await StorageService.file.getData(parentGroupGroupIdsPath);
    List<dynamic> parentGroupGroupIds = parentGroupGroupIdsData[AppKeys.data];
    parentGroupGroupIds.remove(groupId);
    await StorageService.file.setData(
      path: parentGroupGroupIdsPath,
      data: {AppKeys.data: parentGroupGroupIds},
    );
    await StorageService.directory.delete(groupPath);
  }

  //Future<void> edit() async {}

  //Future<void> move(Group group, Group oldParentGroup, Group newParentGroup) async {}
}

class _NoteService {
  const _NoteService._();

  Future<List<NoteInfo>> getNoteInfos(String groupPath) async {
    List<NoteInfo> noteInfos = [];
    final Map<String, dynamic> noteIdsData =
        await StorageService.file.getData(PathService().groupNoteIds(groupPath));
    final List<dynamic> noteIds = noteIdsData[AppKeys.data] ?? [];
    for (String noteId in noteIds) {
      noteInfos.add(IdService.decodeNoteInfo(noteId));
    }
    return noteInfos;
  }

  Future<NoteInfo> tryCreateNoteInfo({required String groupPath, required NoteType type}) async {
    //TODO: Improve naming
    final List<NoteInfo> groupNoteInfos = await getNoteInfos(groupPath);
    List<int> noteNumbers =
        groupNoteInfos.map((groupNoteInfo) => int.parse(groupNoteInfo.name.split('_')[1])).toList();
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
    return NoteInfo(
      name: 'note_$newNoteNumber',
      dateTime: DateTime.now(),
      type: type,
    );
  }

  Future<String> tryCreate({
    required String groupPath,
    required String realMediaPath,
    required NoteInfo noteInfo,
    bool deleteOriginalFile = true,
  }) async {
    try {
      final String id = IdService.encodeNoteInfo(noteInfo);
      final Map<String, dynamic> noteIdsData =
          await StorageService.file.getData(PathService().groupNoteIds(groupPath));
      List<dynamic> noteIds = noteIdsData[AppKeys.data] ?? [];
      if (ItemService()._isNameExist(name: noteInfo.name, ids: noteIds)) return AppKeys.nameExist;
      noteIds.add(id);
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
      return AppKeys.done;
    } catch (_) {
      return AppKeys.error;
    }
  }

  Future<Note> get(String notePath) async {
    return Note(
      path: notePath,
      info: IdService.decodeNoteInfo(PathService().id(notePath)),
      file: StorageService.file.get(PathService().noteFile(PathService().id(notePath))),
    );
  }

  Future<void> deleteNote(String notePath) async {
    final String id = PathService().id(notePath);
    final String groupNoteIdsPath = PathService().groupNoteIds(PathService().groupOfNote(notePath));
    final Map<String, dynamic> groupNoteIdsData =
        await StorageService.file.getData(groupNoteIdsPath);
    List<dynamic> groupNoteIds = groupNoteIdsData[AppKeys.data];
    groupNoteIds.remove(id);
    await StorageService.file.setData(
      path: groupNoteIdsPath,
      data: {
        AppKeys.data: groupNoteIds,
      },
    );
    await StorageService.file.delete(notePath);
    await StorageService.file.delete(PathService().noteFile(id));
  }
  // Future<void> edit() async {}
  //Future<void> move(Note note, Group oldParentGroup, Group newParentGroup) async {}
}
