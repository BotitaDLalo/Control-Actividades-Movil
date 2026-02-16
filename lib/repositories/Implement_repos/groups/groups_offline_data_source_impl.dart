import 'dart:convert';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_offline_data_source.dart';
import 'package:aprende_mas/config/data/db_local.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:aprende_mas/models/notice_list/notice_model.dart';

class GroupsOfflineDataSourceImpl implements GroupsOfflineDataSource {
@override
Future<List<Group>> getGroupsSubjects() async {
  try {
    final db = await DbLocal.database;
    final querylsGroups = await db.rawQuery('SELECT * FROM tbGrupos');

    if (querylsGroups.isEmpty) return [];

    List<Group> lsGroups = [];

    for (var groupRow in querylsGroups) {
      final int groupId = groupRow['GrupoId'] as int;

      // 🔹 MATERIAS DEL GRUPO
      final querylsGroupsSubjectsId = await db.rawQuery(
        "SELECT MateriaId FROM tbGruposMaterias WHERE GrupoId = ?",
        [groupId],
      );

      List<Subject> materias = [];

      for (var subjectRow in querylsGroupsSubjectsId) {
        final int subjectId = subjectRow['MateriaId'] as int;

        final querySubject = await db.rawQuery(
          "SELECT * FROM tbMaterias WHERE MateriaId = ?",
          [subjectId],
        );

        final queryActivities = await db.query(
          'tbActividades',
          where: 'MateriaId = ?',
          whereArgs: [subjectId],
        );

        final actividades = queryActivities.map((row) {
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

        materias.add(Subject(
          materiaId: subjectId,
          nombreMateria: querySubject[0]['NombreMateria'] as String,
          descripcion: querySubject[0]['Descripcion'] as String,
          codigoAcceso: querySubject[0]['CodigoAcceso'] as String,
          actividades: actividades,
        ));
      }

      // 🔹 AVISOS DEL GRUPO
      final queryNotices = await db.query(
        'tbAvisos',
        where: 'GrupoId = ?',
        whereArgs: [groupId],
      );

      final avisos = queryNotices.map((row) {
        return NoticeModel(
          noticeId: row['AvisoId'] as int,
          title: row['Titulo'] as String,
          description: row['Descripcion'] as String,
          createdDate: formatDate(row['FechaCreacion'] as String),
          teacherFullName: row['DocenteNombre'] as String?,
          groupId: row['GrupoId'] as int? ?? 0,
          subjectId: row['MateriaId'] as int? ?? 0,
          startDate: row['FechaInicio'] as String?,
          endDate: row['FechaFin'] as String?,
          links: row['Enlaces'] is List ? jsonEncode(row['Enlaces']) : row['Enlaces'] as String?,
          frequencyDays: row['FrecuenciaDias'] as int? ?? 0,
        );
      }).toList();

      // 🔹 CONSTRUIR GRUPO (UNA SOLA VEZ)
      lsGroups.add(Group(
        grupoId: groupId,
        nombreGrupo: groupRow['NombreGrupo'] as String,
        descripcion: groupRow['Descripcion'] as String,
        codigoAcceso: groupRow['CodigoAcceso'] as String,
        materias: materias,
        avisos: avisos,
      ));
    }

    return lsGroups;
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
                  'Descripcion': activity.descripcion,
                  'FechaCreacion': activity.fechaCreacion.toString(),
                  'FechaLimite': activity.fechaLimite.toString(),
                  'Puntaje': activity.puntaje,
                  'MateriaId': subjectId,
                  'PermitirEntregasTarde': activity.permitirEntregasTarde ? 1 : 0,
                  'TieneLimiteEntregas': activity.tieneLimiteEntregas ? 1 : 0,
                  'LimiteEntregasPorAlumno': activity.limiteEntregasPorAlumno,
                  
                }, conflictAlgorithm: ConflictAlgorithm.replace);

              }
            }
            if (group.avisos != null) {
              for (final notice in group.avisos!) {
                await db.insert(
                  'tbAvisos',
                  {
                  'AvisoId': notice.noticeId,
                  'Titulo': notice.title,
                  'Descripcion': notice.description,
                  'FechaCreacion': notice.createdDate.toString(),
                  'GrupoId': groupId,
                  'MateriaId': notice.subjectId != 0 ? notice.subjectId : null,
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
        }
      }
    } catch (e) {
      debugPrint('Error en saveGroupSubjects: $e');
      rethrow;
    }
  }
}
