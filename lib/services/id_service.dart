import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_id_code_maps.dart';
import 'package:note_repository/constants/app_id_codes.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/id_block.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/services/time_service.dart';

class IdService {
  IdService._();

  static String _encode(IdBlock idBlock) {
    String id = '';
    List<String> idCodes = [];
    String typeCode = '';
    String dataCode = '';
    List<dynamic> idDataList = [
      idBlock.itemType,
      idBlock.color,
      idBlock.noteType,
    ];
    idDataList.removeWhere((element) => element == null);
    for (dynamic idData in idDataList) {
      AppIdCodeMaps.codeTypeMap.forEach((codeTypeMapKey, codeGroup) {
        codeGroup.forEach((key, value) {
          if (value == idData) {
            typeCode = codeTypeMapKey;
            dataCode = key;
          }
        });
      });
      idCodes.add(typeCode + AppIdCodes.idCodeTypeSeparator + dataCode);
    }
    for (dynamic idData in idDataList) {
      search:
      for (String codeTypeKey in AppIdCodeMaps.codeTypeMap.keys) {
        for (dynamic key in AppIdCodeMaps.codeTypeMap[codeTypeKey]!.keys) {
          if (idData == AppIdCodeMaps.codeTypeMap[codeTypeKey]![key]) {
            typeCode = codeTypeKey;
            dataCode = key;
            break search;
          }
        }
      }
    }
    id += AppIdCodes.idStartCode;
    for (String idCode in idCodes) {
      id += AppIdCodes.idCodeSeparator;
      id += idCode;
    }
    id += AppIdCodes.idCodeSeparator;
    id += TimeService().encode(idBlock.dateTime);
    id += AppIdCodes.idCodeSeparator;
    id += idBlock.name;
    return id;
  }

  static IdBlock _decode(String id) {
    String name = '';
    DateTime dateTime;
    List<String> idBlockCodes = id.split(AppIdCodes.idCodeSeparator);
    idBlockCodes.removeAt(0);
    name = idBlockCodes.last;
    idBlockCodes.removeLast();
    dateTime = TimeService().decode(idBlockCodes.last);
    idBlockCodes.removeLast();
    Map<String, dynamic> idBlockMap = {};
    List<String> splittedCode = [];
    String typeCode = '';
    String dataCode = '';
    for (var idBlockCode in idBlockCodes) {
      splittedCode = idBlockCode.split(AppIdCodes.idCodeTypeSeparator);
      typeCode = splittedCode[0];
      dataCode = splittedCode[1];
      idBlockMap[typeCode] = AppIdCodeMaps.codeTypeMap[typeCode]![dataCode];
    }
    return IdBlock(
      name: name,
      dateTime: dateTime,
      itemType: idBlockMap[AppIdCodes.item],
      color: idBlockMap[AppIdCodes.color],
      noteType: idBlockMap[AppIdCodes.noteType],
    );
  }

  static String encodeGroupInfo(GroupInfo groupInfo) {
    return _encode(
      IdBlock(
        itemType: Group,
        name: groupInfo.name,
        dateTime: groupInfo.dateTime,
        color: groupInfo.color,
      ),
    );
  }

  static GroupInfo decodeGroupInfo(String id) {
    IdBlock idBlock = _decode(id);
    return GroupInfo(
      name: idBlock.name,
      dateTime: idBlock.dateTime,
      color: idBlock.color ?? Colors.transparent,
    );
  }

  static String encodeNoteInfo(NoteInfo noteInfo) {
    return _encode(
      IdBlock(
        itemType: Note,
        name: noteInfo.name,
        dateTime: noteInfo.dateTime,
        noteType: noteInfo.type,
      ),
    );
  }

  static NoteInfo decodeNoteInfo(String id) {
    IdBlock idBlock = _decode(id);
    return NoteInfo(
      name: idBlock.name,
      dateTime: idBlock.dateTime,
      type: idBlock.noteType!,
    );
  }
}
