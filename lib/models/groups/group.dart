import 'dart:ui';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/models/models.dart';

class Group {
  final int? grupoId;
  final String nombreGrupo;
  final String? descripcion;
  final String? codigoAcceso;
  // final String codigoColor;
  final List<Subject>? materias;

  Group({
    this.grupoId,
    required this.nombreGrupo,
    this.descripcion,
    this.codigoAcceso,
    // required this.codigoColor,
    this.materias,
  });

  static Group empty() => Group(
        grupoId: -1,
        descripcion: '',
        nombreGrupo: '',
        codigoAcceso: '',
        // codigoColor: ''
      );

  static List<Group> groupsJsonToEntityList(
      List<Map<String, dynamic>> groupsAndSubject) {
    List<Group> groups = [];

    for (var group in groupsAndSubject) {
      List<Subject> materias =
          (group['Materias'] as List? ?? []).map((materia) {
        List<Activity> actividades =
            (materia['Actividades'] as List? ?? []).map((actividad) {
          return Activity(
              activityId: actividad['ActividadId'],
              nombreActividad: actividad['NombreActividad'],
              descripcion: actividad['Descripcion'],
              tipoActividadId: actividad['TipoActividadId'],
              fechaCreacion: formatDate(actividad['FechaCreacion']),
              fechaLimite: formatDate(actividad['FechaLimite']),
              puntaje: actividad['Puntaje'],
              materiaId: actividad['MateriaId']);
        }).toList();

        return Subject(
          materiaId: materia['MateriaId'],
          nombreMateria: materia['NombreMateria'],
          descripcion: materia['Descripcion'] ?? "",
          codigoColor: materia['CodigoColor'] ?? "",
          codigoAcceso: materia['CodigoAcceso'] ?? "",
          actividades: actividades,
        );
      }).toList();

      groups.add(Group(
        grupoId: group['GrupoId'],
        nombreGrupo: group['NombreGrupo'],
        descripcion: group['Descripcion'] ?? "",
        codigoAcceso: group['CodigoAcceso'] ?? "",
        // codigoColor: mainColorToHex,
        materias: materias,
      ));
    }
    return groups;
  }

  static Group mapToEntity(Map<String, dynamic> map) => Group(
      grupoId: map['grupoId'],
      nombreGrupo: map['nombreGrupo'],
      descripcion: map['descripcion'],
      codigoAcceso: map['codigoAcceso'],
      materias: Subject.subjectsJsonToEntityList(
        (map['materias'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      ));

  static Group groupToEntity(Map<String, dynamic> group) => Group(
        grupoId: group['GrupoId'],
        nombreGrupo: group['NombreGrupo'],
        descripcion: group['Descripcion'],
        codigoAcceso: group['CodigoAcceso'],
      );

  static Group queryToEntityGroup(Map<String, Object?> queryGroup) {
    final group = queryGroup as Group;
    return Group(
      nombreGrupo: group.nombreGrupo,
      descripcion: group.descripcion,
      codigoAcceso: group.codigoAcceso,
      // codigoColor: group.codigoColor
    );
  }

  Group copyWith({
    int? grupoId,
    String? nombreGrupo,
    String? descripcion,
    String? codigoAcceso,
    List<Subject>? materias,
  }) {
    return Group(
      grupoId: grupoId ?? this.grupoId,
      nombreGrupo: nombreGrupo ?? this.nombreGrupo,
      descripcion: descripcion ?? this.descripcion,
      codigoAcceso: codigoAcceso ?? this.codigoAcceso,
      materias: materias ?? this.materias,
    );
  }
}
