import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/models/notice_list/notice_model.dart';


class Subject {
  final int? groupId;
  final int materiaId;
  final String nombreMateria;
  final String? codigoAcceso;
  final String? descripcion;
  final String? codigoColor;
  final List<Activity>? actividades;
  final List<NoticeModel>? avisos;
  final Activity? activity;

  Subject({
    this.groupId,
    required this.materiaId,
    required this.nombreMateria,
    this.codigoAcceso,
    this.descripcion,
    this.codigoColor,
    this.actividades,
    this.avisos,
    this.activity,
  });

  static List<Subject> subjectsJsonToEntityList(
      List<Map<String, dynamic>> subjectsJson) {
    return subjectsJson.map((e) {
      return Subject(
        materiaId: e['MateriaId'],
        nombreMateria: e['NombreMateria'],
        descripcion: e['Descripcion'],
        codigoAcceso: e['CodigoAcceso'],
        actividades: (e['Actividades'] as List<dynamic>? ?? [])
            .map((a) => Activity(
                  activityId: a['ActividadId'],
                  nombreActividad: a['NombreActividad'],
                  descripcion: a['Descripcion'],
                  //tipoActividadId: a['TipoActividadId'],
                  fechaCreacion: formatDate(a['FechaCreacion']),
                  fechaLimite: formatDate(a['FechaLimite']),
                  puntaje: a['Puntaje'],
                  materiaId: a['MateriaId'],
                ))
            .toList(),
        avisos: (e['Avisos'] as List<dynamic>? ?? [])
            .map((n) => NoticeModel(
              noticeId: n['AvisoId'] as int?,
              title: n['Titulo'] as String,
              description: n['Descripcion'] as String,
              createdDate: formatDate(n['FechaCreacion'] as String),
              teacherFullName: n['DocenteNombre'] as String?, // 👈 NUEVO
              groupId: n['GrupoId'] as int? ?? 0,
              subjectId: n['MateriaId'] as int? ?? 0,
            ))
            .toList(),
      );
    }).toList();
  }

  static Subject mapToEntity(Map<String, dynamic> map) => Subject(
      materiaId: map['MateriaId'],
      nombreMateria: map['NombreMateria'],
      descripcion: map['Descripcion'],
      codigoAcceso: map['CodigoAcceso'],
      actividades: (map['Actividades'] as List<dynamic>? ?? [])
          .map((e) => Activity(
              activityId: e['ActividadId'],
              nombreActividad: e['NombreActividad'],
              descripcion: e['Descripcion'],
              tipoActividadId: e['TipoActividadId'],
              fechaCreacion: formatDate(e['FechaCreacion']),
              fechaLimite: formatDate(e['FechaLimite']),
              puntaje: e['Puntaje'],
              materiaId: map['MateriaId'])) // Usar el materiaId del Subject padre
          .toList());
}
