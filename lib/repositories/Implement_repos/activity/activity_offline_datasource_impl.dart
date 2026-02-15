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
    try {
      final db = await DbLocal.database;
      final querylsActivitiesId = await db.query('tbActividades',
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
    } catch (e) {
      debugPrint('Error en getAllActivitiesOffline: $e');
      return [];
    }
  }

//Nuevo metdodo para llamar actividades offline por materia
/*@override
Future<List<Activity>> getAllActivitiesOffline(int subjectId) async {
  try {
    final db = await DbLocal.database;

    final querylsActivities = await db.query(
      'tbActividades',
      where: 'MateriaId = ?',
      whereArgs: [subjectId],
    );

    return Activity.queryToEntityActivity(querylsActivities);
  } catch (e) {
    debugPrint('Error en getAllActivitiesOffline: $e');
    return [];
  }
}*/


  @override
  Future<void> saveSubmissions(
      List<Submission> lsSubmissions, int activityId) async {
    try {
      final db = await DbLocal.database;
      final id = await storageService.getId();

      for (var sub in lsSubmissions) {
        await db.transaction(
          (txn) async {
            // 1. Verificar si ya existe el registro padre (tbEntregableActividadAlumno)
            final existing = await txn.query(
              'tbEntregableActividadAlumno',
              columns: ['EntregaActividadAlumnoId'],
              where: 'ActividadId = ? AND UsuarioId = ?',
              whereArgs: [activityId, id],
            );

            int entregaActividadAlumnoId;

            if (existing.isEmpty) {
              // Insertar nuevo
              entregaActividadAlumnoId = await txn.insert('tbEntregableActividadAlumno', {
                'ActividadId': activityId,
                'UsuarioId': id,
                'FechaEntrega': sub.submissionDate,
                'EstadoEntregaId': sub.status! ? 1 : 0 // 1: Enviado, 0: Pendiente
              });
            } else {
              // Actualizar existente
              entregaActividadAlumnoId = existing.first['EntregaActividadAlumnoId'] as int;
              await txn.update(
                'tbEntregableActividadAlumno',
                {
                  'FechaEntrega': sub.submissionDate,
                  'EstadoEntregaId': sub.status! ? 1 : 0
                },
                where: 'EntregaActividadAlumnoId = ?',
                whereArgs: [entregaActividadAlumnoId],
              );
            }

            // 2. Insertar el entregable (tbEntregables)
            // Primero limpiamos entregables previos de esta entrega para evitar duplicados al sincronizar
            await txn.delete('tbEntregables', 
                where: 'EntregaActividadAlumnoId = ?', 
                whereArgs: [entregaActividadAlumnoId]);

            await txn.insert('tbEntregables', {
              'EntregaActividadAlumnoId': entregaActividadAlumnoId,
              'TipoEntregaId': 1, // 1 = Texto (según cTipoEntregas)
              'Contenido': sub.answer
            });
          },
        );
      }
    } catch (e) {
      debugPrint('Error en saveSubmissions: $e');
      rethrow;
    }
  }

  @override
  Future<List<Submission>> getSubmissionsOffline(int activityId) async {
    try {
      final db = await DbLocal.database;
      final id = await storageService.getId();
      List<Submission> lsSubmisions = [];
      
      // Consultamos la tabla nueva tbEntregableActividadAlumno
      final querylsStudentActivities = await db.query('tbEntregableActividadAlumno',
          columns: ['EntregaActividadAlumnoId', 'FechaEntrega', 'EstadoEntregaId'],
          where: 'ActividadId = ? AND UsuarioId = ?',
          whereArgs: [activityId, id]);

      for (var sa in querylsStudentActivities) {
        int studentActivityId = sa['EntregaActividadAlumnoId'] as int;
        String submissionDate = sa['FechaEntrega'] as String;
        bool status = (sa['EstadoEntregaId'] as int) == 1;

        // Consultamos la tabla nueva tbEntregables
        final querylsSubmissions = await db.query('tbEntregables',
            columns: ['EntregableId', 'Contenido'],
            where: 'EntregaActividadAlumnoId = ?',
            whereArgs: [studentActivityId]);

        for (var sub in querylsSubmissions) {
          Submission submission = Submission(
              submissionId: sub['EntregableId'] as int,
              submissionActivityStudentId: studentActivityId,
              status: status,
              submissionDate: submissionDate);
          
          if (sub['Contenido'] != null) {
            submission.answer = sub['Contenido'] as String;
          }
          // Nota: Enlace y Archivo no están explícitos en el nuevo esquema tbEntregables (solo Contenido),
          // pero si se agregan columnas o se usa Contenido para todo, ajusta aquí.
          
          submission.activityId = activityId;
          lsSubmisions.add(submission);
        }
      }

      return lsSubmisions;
    } catch (e) {
      debugPrint('Error en getSubmissionsOffline: $e');
      return [];
    }
  }

  @override
  Future<List<Submission>> sendSubmissionOffline(
      int activityId, String answer) async {
    try {
      final db = await DbLocal.database;
      DateTime dateNow = DateTime.now();
      final id = await storageService.getId();
      
      await db.transaction(
        (txn) async {
          // Verificar si ya existe una entrega local para actualizarla
          final existing = await txn.query('tbEntregableActividadAlumno',
              columns: ['EntregaActividadAlumnoId'],
              where: 'ActividadId = ? AND UsuarioId = ?',
              whereArgs: [activityId, id]);

          int tbId;
          if (existing.isEmpty) {
            tbId = await txn.insert('tbEntregableActividadAlumno', {
              'ActividadId': activityId,
              'UsuarioId': id,
              'FechaEntrega': dateNow.toString(),
              'EstadoEntregaId': 0, // 0 = Pendiente de sincronización
            });
          } else {
            tbId = existing.first['EntregaActividadAlumnoId'] as int;
            await txn.update('tbEntregableActividadAlumno', {
              'FechaEntrega': dateNow.toString(),
              'EstadoEntregaId': 0
            }, where: 'EntregaActividadAlumnoId = ?', whereArgs: [tbId]);
          }

          // Reemplazar entregable anterior si existe
          await txn.delete('tbEntregables', where: 'EntregaActividadAlumnoId = ?', whereArgs: [tbId]);
          
          await txn.insert('tbEntregables', {
            'EntregaActividadAlumnoId': tbId,
            'TipoEntregaId': 1, // Texto
            'Contenido': answer,
          });
        },
      );

      // Retornar la lista actualizada de pendientes
      List<Submission> lsSubmisions = [];
      final querylsStudentActivities = await db.query('tbEntregableActividadAlumno',
          columns: ['EntregaActividadAlumnoId', 'FechaEntrega', 'EstadoEntregaId'],
          where: 'ActividadId = ? AND EstadoEntregaId = 0 AND UsuarioId = ?',
          whereArgs: [activityId, id]);

      for (var sa in querylsStudentActivities) {
        int studentActivityId = sa['EntregaActividadAlumnoId'] as int;
        String submissionDate = sa['FechaEntrega'] as String;
        bool status = (sa['EstadoEntregaId'] as int) == 1;

        final querylsSubmissions = await db.query('tbEntregables',
            columns: ['EntregableId', 'Contenido'],
            where: 'EntregaActividadAlumnoId = ?',
            whereArgs: [studentActivityId]);

        for (var sub in querylsSubmissions) {
          Submission submission = Submission(
              submissionId: sub['EntregableId'] as int,
              submissionActivityStudentId: studentActivityId,
              status: status,
              submissionDate: submissionDate);
          if (sub['Contenido'] != null) {
            submission.answer = sub['Contenido'] as String;
          }
          submission.activityId = activityId;
          lsSubmisions.add(submission);
        }
      }

      return lsSubmisions;
    } catch (e) {
      debugPrint('Error en sendSubmissionOffline: $e');
      return [];
    }
  }

  @override
  Future<List<Submission>> getSubmissionsPending(int activityId) async {
    try {
      final db = await DbLocal.database;
      final id = await storageService.getId();
      List<Submission> lsSubmisions = [];
      
      final querylsStudentActivities = await db.query('tbEntregableActividadAlumno',
          columns: ['EntregaActividadAlumnoId', 'FechaEntrega', 'EstadoEntregaId'],
          where: 'ActividadId = ? AND EstadoEntregaId = 0 AND UsuarioId = ?',
          whereArgs: [activityId, id]);

      for (var sa in querylsStudentActivities) {
        int studentActivityId = sa['EntregaActividadAlumnoId'] as int;
        String submissionDate = sa['FechaEntrega'] as String;
        bool status = (sa['EstadoEntregaId'] as int) == 1;

        final querylsSubmissions = await db.query('tbEntregables',
            columns: ['EntregableId', 'Contenido'],
            where: 'EntregaActividadAlumnoId = ?',
            whereArgs: [studentActivityId]);

        for (var sub in querylsSubmissions) {
          Submission submission = Submission(
              submissionId: sub['EntregableId'] as int,
              submissionActivityStudentId: studentActivityId,
              status: status,
              submissionDate: submissionDate);
          if (sub['Contenido'] != null) {
            submission.answer = sub['Contenido'] as String;
          }
          submission.activityId = activityId;
          lsSubmisions.add(submission);
        }
      }

      return lsSubmisions;
    } catch (e) {
      debugPrint('Error en getSubmissionsPending: $e');
      return [];
    }
  }

  @override
  Future<void> deleteSubmissionOfflineSent(int submissionId) async {
    try {
      final db = await DbLocal.database;
      
      // Buscar el ID del padre antes de borrar el hijo
      final querySubmission = await db.query('tbEntregables',
          columns: ['EntregaActividadAlumnoId'],
          where: 'EntregableId = ?',
          whereArgs: [submissionId]);

      if (querySubmission.isNotEmpty) {
        int studentActivityId = querySubmission.first['EntregaActividadAlumnoId'] as int;

        // Eliminar registro de tbEntregables
        await db.delete('tbEntregables', 
            where: 'EntregableId = ?', 
            whereArgs: [submissionId]);

        // Eliminar registro padre tbEntregableActividadAlumno
        await db.delete('tbEntregableActividadAlumno', 
            where: 'EntregaActividadAlumnoId = ?', 
            whereArgs: [studentActivityId]);
      }
    } catch (e) {
      debugPrint('Error en deleteSubmissionOfflineSent: $e');
      rethrow;
    }
  }

  @override
  Future<List<Submission>> getAllPendingSubmissions() async {
    try {
      final db = await DbLocal.database;
      final id = await storageService.getId();
      List<Submission> lsSubmissions = [];

      // Consulta JOIN para obtener todas las entregas pendientes y sus datos asociados
      final queryResult = await db.rawQuery('''
        SELECT
          ea.ActividadId,
          ea.FechaEntrega,
          e.EntregableId,
          e.Contenido,
          ea.EntregaActividadAlumnoId
        FROM tbEntregableActividadAlumno ea
        JOIN tbEntregables e ON ea.EntregaActividadAlumnoId = e.EntregaActividadAlumnoId
        WHERE ea.UsuarioId = ? AND ea.EstadoEntregaId = 0
      ''', [id]);

      for (var row in queryResult) {
        final submission = Submission(
          submissionId: row['EntregableId'] as int,
          activityId: row['ActividadId'] as int,
          submissionActivityStudentId: row['EntregaActividadAlumnoId'] as int,
          submissionDate: row['FechaEntrega'] as String,
          answer: row['Contenido'] as String?,
          status: false, // Sabemos que es pendiente (0)
        );
        lsSubmissions.add(submission);
      }

      debugPrint("📦 [SYNC] Se encontraron ${lsSubmissions.length} entregas pendientes para sincronizar.");
      return lsSubmissions;

    } catch (e) {
      debugPrint('Error en getAllPendingSubmissions: $e');
      return [];
    }
  }
}
