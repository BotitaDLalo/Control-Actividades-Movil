import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/activities/activity/activity.dart';
import 'package:aprende_mas/models/subjects/subjects.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_offline_data_source.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import '../../../config/utils/packages.dart';

class SubjectsOfflineDataSourceImpl extends SubjectsOfflineDataSource {
  @override
  Future<List<Subject>> getSujectsWithoutGroup() async {
    try {
      final db = await DbLocal.database;
      List<Map<String, Object?>> querylsSubjects =
          await db.rawQuery('SELECT * FROM tbMaterias');

      if (querylsSubjects.isNotEmpty) {
        List<Subject> lsSubjects = [];

        final querylsGroupsSubjects =
            await db.query('tbGruposMaterias', columns: ['MateriaId']);

        List<int> lsSubjectsWithGroupIds = querylsGroupsSubjects
            .map(
              (e) => e['MateriaId'] as int,
            )
            .toList();

        //# Filtra las materias que no tienen grupo
        if (lsSubjectsWithGroupIds.isNotEmpty) {
          querylsSubjects = querylsSubjects.where(
            (e) {
              int subjectId = e['MateriaId'] as int;
              return !lsSubjectsWithGroupIds.contains(subjectId);
            },
          ).toList();
        }

        for (var subjectRow in querylsSubjects) {
          int subjectId = subjectRow['MateriaId'] as int;

          final querylsActivitiesId = await db.rawQuery(
              'SELECT ActividadId FROM tbMateriasActividades WHERE MateriaId = ?',
              [subjectId]);

          List<Activity> lsActivities = [];

          for (var activityIdRow in querylsActivitiesId) {
            int activityId = activityIdRow['ActividadId'] as int;

            final queryActivities = await db.rawQuery(
                'SELECT * FROM tbActividades WHERE ActividadId = ?',
                [activityId]);

            lsActivities.add(Activity(
              activityId: queryActivities[0]['ActividadId'] as int,
              nombreActividad:
                  queryActivities[0]['NombreActividad'] as String,
              descripcion: queryActivities[0]['Descripcion'] as String,
              tipoActividadId: queryActivities[0]['TipoActividadId'] as int,
              fechaCreacion:
                  formatDate(queryActivities[0]['FechaCreacion'] as String),
              fechaLimite:
                  formatDate(queryActivities[0]['FechaLimite'] as String),
              materiaId: queryActivities[0]['MateriaId'] as int,
              puntaje: queryActivities[0]['Puntaje'] as int,
            ));
          }

          lsSubjects.add(Subject(
            materiaId: subjectId,
            nombreMateria: subjectRow['NombreMateria'] as String,
            descripcion: subjectRow['Descripcion'] as String? ?? "",
            codigoAcceso: subjectRow['CodigoAcceso'] as String? ?? "",
            actividades: lsActivities,
          ));
        }

        return lsSubjects;
      }
      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<void> saveSubjectsWithoutGroup(
      List<Subject> lsSubjectsWithoutGroup) async {
    try {
      final db = await DbLocal.database;
      for (var subject in lsSubjectsWithoutGroup) {
        await db.insert('tbMaterias', {
          'MateriaId': subject.materiaId,
          'NombreMateria': subject.nombreMateria,
          'Descripcion': subject.descripcion,
          'CodigoColor': subject.codigoColor,
          'CodigoAcceso': subject.codigoAcceso,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

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
            });

            await db.insert('tbMateriasActividades',
                {'MateriaId': subjectId, 'ActividadId': activity.activityId});
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
