import 'package:aprende_mas/config/utils/general_utils.dart';

class NoticeModel {
  final int? noticeId;
  final String? teacherFullName;
  String title;
  String description;
  final String? createdDate;
  int groupId;
  int subjectId;

  NoticeModel({
    this.noticeId,
    this.teacherFullName,
    this.title = '',
    this.description = '',
    this.createdDate,
    this.groupId = 0,
    this.subjectId = 0,
  });

  NoticeModel copyWith({
    int? noticeId,
    String? teacherFullName,
    String? title,
    String? description,
    String? createdDate,
    int? groupId,
    int? subjectId,
  }) =>
      NoticeModel(
        noticeId: noticeId ?? this.noticeId,
        teacherFullName: teacherFullName ?? this.teacherFullName,
        title: title ?? this.title,
        description: description ?? this.description,
        createdDate: createdDate ?? this.createdDate,
        groupId: groupId ?? this.groupId,
        subjectId: subjectId ?? this.subjectId,
      );

  static List<NoticeModel> jsonToEntitylsNotices(
          List<Map<String, dynamic>> ls) =>
      ls
          .map(
            (e) => NoticeModel(
              noticeId: e['AvisoId'],
              title: e['Titulo'],
              description: e['Descripcion'],
              teacherFullName:
                  "${e['ApePaternoDocente'].toString()} ${e['ApeMaternoDocente'].toString()} ${e['NombresDocente'].toString()}",
              createdDate: formatDate(e['FechaCreacion'].toString()),
              groupId: e['GrupoId'],
              subjectId: e['MateriaId'],
            ),
          )
          .toList();

  static NoticeModel jsonToEntityNotice(Map<String, dynamic> e) => NoticeModel(
        noticeId: e['AvisoId'],
        title: e['Titulo'],
        description: e['Descripcion'],
        teacherFullName:
            "${e['ApePaternoDocente'].toString()} ${e['ApeMaternoDocente'].toString()} ${e['NombresDocente'].toString()}",
        createdDate: formatDate(e['FechaCreacion'].toString()),
        groupId: e['GrupoId'] ?? 0,
        subjectId: e['MateriaId'] ?? 0,
      );
}
