import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';

class Subject {
  final int? groupId;
  final int materiaId;
  final String nombreMateria;
  final String? codigoAcceso;
  final String? descripcion;
  final String? codigoColor;
  // final List<Activities>? actividades;
  final List<Activity>? actividades;
  final Activity? activity;

  Subject({
    this.groupId,
    required this.materiaId,
    required this.nombreMateria,
    this.codigoAcceso,
    this.descripcion,
    this.codigoColor,
    this.actividades,
    this.activity,
  });

  static List<Subject> subjectsJsonToEntityList(
      List<Map<String, dynamic>> subjectsJson) {
    List<Subject> lsSubjects = subjectsJson
        .map((e) => Subject(
            materiaId: e['MateriaId'],
            nombreMateria: e['NombreMateria'],
            descripcion: e['Descripcion'],
            codigoAcceso: e['CodigoAcceso'],
            actividades: (e['Actividades'] as List<dynamic>? ?? [])
                .map((e) => Activity(
                    activityId: e['ActividadId'],
                    nombreActividad: e['NombreActividad'],
                    descripcion: e['Descripcion'],
                    tipoActividadId: e['TipoActividadId'],
                    fechaCreacion: formatDate(e['FechaCreacion']),
                    fechaLimite: formatDate(e['FechaLimite']),
                    puntaje: e['Puntaje'],
                    materiaId: e['MateriaId']))
                .toList()))
        .toList();
    return lsSubjects;
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
              materiaId: e['MateriaId']))
          .toList());
}
