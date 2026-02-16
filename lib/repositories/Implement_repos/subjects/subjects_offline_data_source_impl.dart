import 'dart:convert';
import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/activities/activity/activity.dart';
import 'package:aprende_mas/models/subjects/subjects.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_offline_data_source.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import '../../../config/utils/packages.dart';
import 'package:aprende_mas/models/notice_list/notice_model.dart';

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

          final queryActivities = await db.query(
            'tbActividades',
            where: 'MateriaId = ?',
            whereArgs: [subjectId],
            );


              List<Activity> lsActivities = queryActivities.map((row) {
                return Activity(
                  activityId: row['ActividadId'] as int,
                  nombreActividad: row['NombreActividad'] as String,
                  descripcion: row['Descripcion'] as String,
                  fechaCreacion: formatDate(row['FechaCreacion'] as String),
                  fechaLimite: formatDate(row['FechaLimite'] as String),
                  materiaId: row['MateriaId'] as int,
                  puntaje: (row['Puntaje'] as num?)?.toDouble(),
                );
              }).toList();


          final queryNotices = await db.query(
            'tbAvisos',
            where: 'MateriaId = ? AND GrupoId IS NULL',
            whereArgs: [subjectId],
          );

          List<NoticeModel> lsNotices = queryNotices.map((row) {
            return NoticeModel(
              noticeId: row['AvisoId'] as int,
              title: row['Titulo'] as String,
              description: row['Descripcion'] as String,
              createdDate: formatDate(row['FechaCreacion'] as String),
              teacherFullName: row['DocenteNombre'] as String?,
              subjectId: row['MateriaId'] as int? ?? 0,
              groupId: row['GrupoId'] as int? ?? 0,
              startDate: row['FechaInicio'] as String?,
              endDate: row['FechaFin'] as String?,
              links: row['Enlaces'] is List ? jsonEncode(row['Enlaces']) : row['Enlaces'] as String?,
              frequencyDays: row['FrecuenciaDias'] as int? ?? 0,
            );
          }).toList();

            lsSubjects.add(Subject(
            materiaId: subjectId,
            nombreMateria: subjectRow['NombreMateria'] as String,
            descripcion: subjectRow['Descripcion'] as String? ?? "",
            codigoAcceso: subjectRow['CodigoAcceso'] as String? ?? "",
            actividades: lsActivities,
            avisos: lsNotices,
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
        debugPrint('--- Iniciando saveSubjectsWithoutGroup ---');
        debugPrint('Recibidas ${lsSubjectsWithoutGroup.length} materias para guardar.');

        for (var subject in lsSubjectsWithoutGroup) {
          debugPrint('Procesando materia: ${subject.nombreMateria} (ID: ${subject.materiaId})');
          debugPrint('¿Los avisos son nulos? ${subject.avisos == null}');
          if(subject.avisos != null) {
            debugPrint('Número de avisos: ${subject.avisos!.length}');
          }

          await db.insert(
            'tbMaterias',
            {
              'MateriaId': subject.materiaId,
              'NombreMateria': subject.nombreMateria,
              'Descripcion': subject.descripcion,
              'CodigoColor': subject.codigoColor,
              'CodigoAcceso': subject.codigoAcceso,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          int subjectId = subject.materiaId;

          if (subject.actividades != null) {
            for (var activity in subject.actividades!) {
              await db.insert(
                'tbActividades',
                {
                  'ActividadId': activity.activityId,
                  'NombreActividad': activity.nombreActividad,
                  'Descripcion': activity.descripcion,
                  'FechaCreacion': activity.fechaCreacion.toString(),
                  'FechaLimite': activity.fechaLimite.toString(),
                  'Puntaje': activity.puntaje,
                  'MateriaId': subjectId,
                  'PermitirEntregasTarde': activity.permitirEntregasTarde ? 1 : 0,
                  'TieneLimiteEntregas': activity.tieneLimiteEntregas ? 1 : 0,
                  'LimiteEntregasPorAlumno': activity.limiteEntregasPorAlumno,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          if (subject.avisos != null) {
            for (var notice in subject.avisos!) {
              await db.insert(
                'tbAvisos',
                {
                  'AvisoId': notice.noticeId,
                  'Titulo': notice.title,
                  'Descripcion': notice.description,
                  'FechaCreacion': notice.createdDate.toString(),
                  'GrupoId': null,
                  'MateriaId': subjectId,
                  'DocenteNombre': notice.teacherFullName,
                  'FechaInicio': notice.startDate,
                  'FechaFin': notice.endDate,
                  'Enlaces': notice.links,
                  'FrecuenciaDias': notice.frequencyDays,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
              debugPrint('✅ Aviso insertado');
            }
          }
          
        }

      } catch (e) {
        debugPrint('>>> ERROR en saveSubjectsWithoutGroup: ${e.toString()}');
        rethrow;
      }
    }

}
