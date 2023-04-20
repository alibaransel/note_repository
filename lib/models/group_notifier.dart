import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/models/notifiers.dart';

class GroupNotifier extends SafeValueNotifier<Group> {
  GroupNotifier(
    super._value,
  );

  void addGroupInfo(GroupInfo groupInfo) {
    value.subGroupInfos.add(groupInfo);
    notifyListeners();
  }

  void removeGroupInfo(GroupInfo groupInfo) {
    value.subGroupInfos.removeAt(
      value.subGroupInfos.indexWhere((aGroupInfo) => aGroupInfo.name == groupInfo.name),
    );
    notifyListeners();
  }

  void addNoteInfo(NoteInfo noteInfo) {
    value.noteInfos.add(noteInfo);
    notifyListeners();
  }

  void removeNoteInfo() {}
}
