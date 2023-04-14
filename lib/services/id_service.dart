import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_id_code_maps.dart';
import 'package:note_repository/constants/app_id_codes.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/models/id_block.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/time_service.dart';

class IdService extends Service {
  IdService._();

  static String _encode(IdBlock idBlock) {
    final StringBuffer id = StringBuffer();
    final List<String> idCodes = [];
    String typeCode = '';
    String dataCode = '';
    final List<dynamic> idDataList = [
      idBlock.itemType,
      idBlock.color,
      idBlock.noteType,
    ]..removeWhere((element) => element == null);
    for (final dynamic idData in idDataList) {
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
    for (final dynamic idData in idDataList) {
      search:
      for (final String codeTypeKey in AppIdCodeMaps.codeTypeMap.keys) {
        for (final String key in AppIdCodeMaps.codeTypeMap[codeTypeKey]!.keys) {
          if (idData == AppIdCodeMaps.codeTypeMap[codeTypeKey]![key]) {
            typeCode = codeTypeKey;
            dataCode = key;
            break search;
          }
        }
      }
    }
    id.write(AppIdCodes.idStartCode);
    for (final String idCode in idCodes) {
      id
        ..write(AppIdCodes.idCodeSeparator)
        ..write(idCode);
    }
    id
      ..write(AppIdCodes.idCodeSeparator)
      ..write(TimeService.encode(idBlock.dateTime))
      ..write(AppIdCodes.idCodeSeparator)
      ..write(idBlock.name);
    return id.toString();
  }

  static IdBlock _decode(String id) {
    String name = '';
    DateTime dateTime;
    final List<String> idBlockCodes = id.split(AppIdCodes.idCodeSeparator).sublist(1);
    name = idBlockCodes.last;
    idBlockCodes.removeLast();
    dateTime = TimeService.decode(idBlockCodes.last);
    idBlockCodes.removeLast();
    final Map<String, dynamic> idBlockMap = {};
    List<String> splitCode = [];
    String typeCode = '';
    String dataCode = '';
    for (final idBlockCode in idBlockCodes) {
      splitCode = idBlockCode.split(AppIdCodes.idCodeTypeSeparator);
      typeCode = splitCode[0];
      dataCode = splitCode[1];
      idBlockMap[typeCode] = AppIdCodeMaps.codeTypeMap[typeCode]![dataCode];
    }
    return IdBlock(
      name: name,
      dateTime: dateTime,
      itemType: idBlockMap[AppIdCodes.item] as Type,
      color: idBlockMap[AppIdCodes.color] as Color?,
      noteType: idBlockMap[AppIdCodes.noteType] as NoteType?,
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
    final IdBlock idBlock = _decode(id);
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
    final IdBlock idBlock = _decode(id);
    return NoteInfo(
      name: idBlock.name,
      dateTime: idBlock.dateTime,
      type: idBlock.noteType!,
    );
  }
}
