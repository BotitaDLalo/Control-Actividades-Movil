import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_offline_data_source.dart';
import 'package:aprende_mas/config/data/db_local.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class GroupsOfflineDataSourceImpl implements GroupsOfflineDataSource {
  @override
  Future<List<Group>> getGroupsSubjects() async {
    try {
      final db = await DbLocal.database;
      final querylsGroups = await db.rawQuery('SELECT * FROM tbGrupos');

      if (querylsGroups.isNotEmpty) {
        List<Group> lsGroups = [];

        for (var groupRow in querylsGroups) {
          int groupId = groupRow['GrupoId'] as int;

          final querylsGroupsSubjectsId = await db.rawQuery(
              "SELECT MateriaId FROM tbGruposMaterias WHERE GrupoId = ?",
              [groupId]);

          List<Subject> materias = [];

          for (var subjectRow in querylsGroupsSubjectsId) {
            int subjectId = subjectRow['MateriaId'] as int;

            final querySubject = await db.rawQuery(
                "SELECT * FROM tbMaterias WHERE MateriaId = ?", [subjectId]);

            final querylsActivitiesId = await db.rawQuery(
                "SELECT ActividadId FROM tbMateriasActividades WHERE MateriaId = ?",
                [subjectId]);

            List<Activity> actividades = [];

            for (var activityRow in querylsActivitiesId) {
              int activityId = activityRow['ActividadId'] as int;

              final queryActivitie = await db.rawQuery(
                  "SELECT * FROM tbActividades WHERE ActividadId = ?",
                  [activityId]);

              actividades.add(Activity(
                  activityId: queryActivitie[0]['ActividadId'] as int,
                  nombreActividad:
                      queryActivitie[0]['NombreActividad'] as String,
                  descripcion: queryActivitie[0]['Descripcion'] as String,
                  tipoActividadId:
                      queryActivitie[0]['TipoActividadId'] as int,
                  fechaCreacion: formatDate(
                      queryActivitie[0]['FechaCreacion'] as String),
                  fechaLimite:
                      formatDate(queryActivitie[0]['FechaLimite'] as String),
                  materiaId: queryActivitie[0]['MateriaId'] as int,
                  puntaje: queryActivitie[0]['Puntaje'] as int));
            }

            materias.add(Subject(
              materiaId: subjectId,
              nombreMateria: querySubject[0]['NombreMateria'] as String,
              descripcion: querySubject[0]['Descripcion'] as String,
              codigoAcceso: querySubject[0]['CodigoAcceso'] as String,
              actividades: actividades,
            ));
          }

          lsGroups.add(Group(
            grupoId: groupRow['GrupoId'] as int,
            nombreGrupo: groupRow['NombreGrupo'] as String,
            descripcion: groupRow['Descripcion'] as String,
            codigoAcceso: groupRow['CodigoAcceso'] as String,
            materias: materias,
          ));
        }

        return lsGroups;
      }

      return [];
    } catch (e) {
      debugPrint('Error en getGroupsSubjects: $e');
      return [];
    }
  }

  @override
  Future<void> saveGroupSubjects(List<Group> lsGroups) async {
    try {
      final db = await DbLocal.database;
      for (var group in lsGroups) {
        await db.transaction(
          (txn) async {
            await txn.insert('tbGrupos', {
              'GrupoId': group.grupoId,
              'NombreGrupo': group.nombreGrupo,
              'Descripcion': group.descripcion,
              'CodigoAcceso': group.codigoAcceso
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          },
        );

        int groupId = group.grupoId ?? 0;

        if (group.materias != null) {
          for (var subject in group.materias!) {
            await db.insert('tbMaterias', {
              'MateriaId': subject.materiaId,
              'NombreMateria': subject.nombreMateria,
              'Descripcion': subject.descripcion,
              'CodigoAcceso': subject.codigoAcceso
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            await db.insert('tbGruposMaterias',
                {'GrupoId': groupId, 'MateriaId': subject.materiaId},
                conflictAlgorithm: ConflictAlgorithm.ignore);

            int subjectId = subject.materiaId;

            if (subject.actividades != null) {
              for (var activity in subject.actividades!) {
                await db.insert('tbActividades', {
                  'ActividadId': activity.activityId,
                  'NombreActividad': activity.nombreActividad,
                  'TipoActividadId': activity.tipoActividadId,
                  'Descripcion': activity.descripcion,
                  'FechaCreacion': activity.fechaCreacion.toString(),
                  'FechaLimite': activity.fechaLimite.toString(),
                  'MateriaId': subjectId,
                  'Puntaje': activity.puntaje
                }, conflictAlgorithm: ConflictAlgorithm.replace);

                await db.insert('tbMateriasActividades', {
                  'MateriaId': subjectId,
                  'ActividadId': activity.activityId
                }, conflictAlgorithm: ConflictAlgorithm.ignore);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error en saveGroupSubjects: $e');
      rethrow;
    }
  }
}
