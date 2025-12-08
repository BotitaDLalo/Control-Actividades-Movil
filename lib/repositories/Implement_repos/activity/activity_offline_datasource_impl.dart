import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_datasource.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/data/db_local.dart';
import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

import '../../../config/utils/packages.dart';

class ActivityOfflineDatasourceImpl implements ActivityOfflineDatasource {
  final storageService = KeyValueStorageServiceImpl();
  @override
  Future<List<Activity>> getAllActivitiesOffline(int subjectId) async {
    Database? db;
    try {
      db = await DbLocal.initDatabase();
      if (db.isOpen) {
        final querylsActivitiesId = await db.query('tbMateriasActividades',
            columns: ['ActividadId'],
            where: '"MateriaId" = ?',
            whereArgs: [subjectId]);

        final lsActivitiesId = querylsActivitiesId
            .map(
              (e) => e['ActividadId'] as int,
            )
            .toList();

        final placeholders = List.filled(lsActivitiesId.length, '?').join(',');

        String query =
            "SELECT * FROM tbActividades WHERE ActividadId IN ($placeholders)";

        final querylsActivities = await db.rawQuery(query, lsActivitiesId);

        final lsActivities = Activity.queryToEntityActivity(querylsActivities);

        return lsActivities;
      }

      return [];
    } catch (e) {
      debugPrint('Error en getAllActivitiesOffline: $e');
      return [];
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  @override
  Future<void> saveSubmissions(
      List<Submission> lsSubmissions, int activityId) async {
    Database? db;
    try {
      db = await DbLocal.initDatabase();
      if (db.isOpen) {
        final id = await storageService.getId();

        for (var sub in lsSubmissions) {
          int tbId = await db.transaction(
            (txn) async {
              return await txn.insert('tbAlumnosActividades', {
                'ActividadId': activityId,
                'AlumnoId': id,
                'FechaEntrega': sub.submissionDate,
                'EstatusEntrega': sub.status
              });
            },
          );

          await db.insert('tbEntregableActividades',
              {'AlumnoActividadId': tbId, 'Respuesta': sub.answer});
        }
      }
    } catch (e) {
      debugPrint('Error en saveSubmissions: $e');
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  @override
  Future<List<Submission>> getSubmissionsOffline(int activityId) async {
    Database? db;
    try {
      db = await DbLocal.initDatabase();
      if (db.isOpen) {
        List<Submission> lsSubmisions = [];
        final querylsStudentActivities = await db.query('tbAlumnosActividades',
            columns: ['AlumnoActividadId', 'FechaEntrega', 'EstatusEntrega'],
            where: '"ActividadId" = ?',
            whereArgs: [activityId]);

        for (var sa in querylsStudentActivities) {
          int studentActivityId = sa['AlumnoActividadId'] as int;
          String submissionDate = sa['FechaEntrega'] as String;
          bool status = sa['EstatusEntrega'] == 1 ? true : false;

          final querylsSubmissions = await db.query('tbEntregableActividades',
              columns: ['EntregaId', 'Respuesta'],
              where: '"AlumnoActividadId" = ?',
              whereArgs: [studentActivityId]);

          for (var sub in querylsSubmissions) {
            Submission submission = Submission(
                submissionId: sub['EntregaId'] as int,
                studentActivityId: studentActivityId,
                status: status,
                submissionDate: submissionDate);
            if (sub['Respuesta'] != null) {
              submission.answer = sub['Respuesta'] as String;
            }
            if (sub['Enlace'] != null) {
              submission.answer = sub['Enlace'] as String;
            }
            if (sub['Archivo'] != null) {
              submission.answer = sub['Archivo'] as String;
            }
            submission.activityId = activityId;
            lsSubmisions.add(submission);
          }
        }

        return lsSubmisions;
      }
      return [];
    } catch (e) {
      debugPrint('Error en getSubmissionsOffline: $e');
      return [];
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  @override
  Future<List<Submission>> sendSubmissionOffline(
      int activityId, String answer) async {
    Database? db;
    try {
      db = await DbLocal.initDatabase();

      if (db.isOpen) {
        DateTime dateNow = DateTime.now();
        final id = await storageService.getId();
        await db.transaction(
          (txn) async {
            int tbId = await txn.insert('tbAlumnosActividades', {
              'ActividadId': activityId,
              'AlumnoId': id,
              'FechaEntrega': dateNow.toString(),
              'EstatusEntrega': false,
            });

            await txn.insert('tbEntregableActividades', {
              'AlumnoActividadId': tbId,
              'Respuesta': answer,
            });
          },
        );

        List<Submission> lsSubmisions = [];
        final querylsStudentActivities = await db.query('tbAlumnosActividades',
            columns: ['AlumnoActividadId', 'FechaEntrega', 'EstatusEntrega'],
            where: '"ActividadId" = ? AND "EstatusEntrega"=?',
            whereArgs: [activityId, 0]);

        for (var sa in querylsStudentActivities) {
          int studentActivityId = sa['AlumnoActividadId'] as int;
          String submissionDate = sa['FechaEntrega'] as String;
          bool status = sa['EstatusEntrega'] == 1 ? true : false;

          final querylsSubmissions = await db.query('tbEntregableActividades',
              columns: ['EntregaId', 'Respuesta'],
              where: '"AlumnoActividadId" = ?',
              whereArgs: [studentActivityId]);

          for (var sub in querylsSubmissions) {
            Submission submission = Submission(
                submissionId: sub['EntregaId'] as int,
                studentActivityId: studentActivityId,
                status: status,
                submissionDate: submissionDate);
            if (sub['Respuesta'] != null) {
              submission.answer = sub['Respuesta'] as String;
            }
            if (sub['Enlace'] != null) {
              submission.answer = sub['Enlace'] as String;
            }
            if (sub['Archivo'] != null) {
              submission.answer = sub['Archivo'] as String;
            }
            submission.activityId = activityId;
            lsSubmisions.add(submission);
          }
        }

        //TODO: RETORNA EL LIST SUBMISSION
        return lsSubmisions;
      }
      return [];
    } catch (e) {
      debugPrint('Error en sendSubmissionOffline: $e');
      return [];
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  @override
  Future<List<Submission>> getSubmissionsPending(int activityId) async {
    Database? db;
    try {
      db = await DbLocal.initDatabase();
      if (db.isOpen) {
        List<Submission> lsSubmisions = [];
        final querylsStudentActivities = await db.query('tbAlumnosActividades',
            columns: ['AlumnoActividadId', 'FechaEntrega', 'EstatusEntrega'],
            where: '"ActividadId" = ? AND "EstatusEntrega"=?',
            whereArgs: [activityId, 0]);

        for (var sa in querylsStudentActivities) {
          int studentActivityId = sa['AlumnoActividadId'] as int;
          String submissionDate = sa['FechaEntrega'] as String;
          bool status = sa['EstatusEntrega'] == 1 ? true : false;

          final querylsSubmissions = await db.query('tbEntregableActividades',
              columns: ['EntregaId', 'Respuesta'],
              where: '"AlumnoActividadId" = ?',
              whereArgs: [studentActivityId]);

          for (var sub in querylsSubmissions) {
            Submission submission = Submission(
                submissionId: sub['EntregaId'] as int,
                studentActivityId: studentActivityId,
                status: status,
                submissionDate: submissionDate);
            if (sub['Respuesta'] != null) {
              submission.answer = sub['Respuesta'] as String;
            }
            if (sub['Enlace'] != null) {
              submission.answer = sub['Enlace'] as String;
            }
            if (sub['Archivo'] != null) {
              submission.answer = sub['Archivo'] as String;
            }
            submission.activityId = activityId;
            lsSubmisions.add(submission);
          }
        }

        return lsSubmisions;
      }
      return [];
    } catch (e) {
      debugPrint('Error en getSubmissionsPending: $e');
      return [];
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  @override
  Future<void> deleteSubmissionOfflineSent(int submissionId) async {
    Database? db;
    try {
      /**
       * tbEntregableActividades
       * tbAlumnosActividades
       */

      db = await DbLocal.initDatabase();

      if (db.isOpen) {
        final querySubmission = await db.query('tbEntregableActividades',
            columns: ['AlumnoActividadId'],
            where: ' "EntregaId" = ? ',
            whereArgs: [submissionId]);

        int studentActivityId = querySubmission.first['AlumnoActividadId'] as int;

        //& Eliminando registros tbEntregableActividades y tbAlumnosActividades
        await db.rawDelete(
            'DELETE FROM tbEntregableActividades WHERE EntregaId = ?',
            [submissionId]);

        await db.rawDelete(
            'DELETE FROM tbAlumnosActividades WHERE AlumnoActividadId = ?',
            [studentActivityId]);
      }
    } catch (e) {
      debugPrint('Error en deleteSubmissionOfflineSent: $e');
    } finally {
      // Asegurarse de cerrar la base de datos siempre
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }
}
