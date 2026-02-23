import 'package:aprende_mas/models/notice_list/notice_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_data_source.dart';
import 'package:aprende_mas/config/data/db_local.dart';
import 'dart:convert';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';


class NoticesOfflineDatasourceImpl implements NoticesOfflineDatasource {

  @override
  Future<List<NoticeModel>> getNoticesOffline({
    int? subjectId,
    int? groupId,
  }) async {
    try {
      final db = await DbLocal.database;

      // 🔒 Seguridad: debe venir al menos uno
      if (subjectId == null && groupId == null) {
        debugPrint('⚠️ getNoticesOffline llamado sin subjectId ni groupId');
        return [];
      }

      String whereClause;
      List<Object?> whereArgs;

      //  Avisos por grupo (Prioridad: Si hay groupId, buscamos por grupo)
      if (groupId != null && groupId != 0) {
        debugPrint('🔍 [Offline] Buscando avisos por GrupoId: $groupId');
        whereClause = 'GrupoId = ?';
        whereArgs = [groupId];
      }
      // 📘 Avisos por materia (Si no hay grupo, buscamos generales de la materia)
      else if (subjectId != null && subjectId != 0) {
        debugPrint('🔍 [Offline] Buscando avisos por MateriaId: $subjectId (GrupoId IS NULL)');
        whereClause = 'MateriaId = ? AND GrupoId IS NULL';
        whereArgs = [subjectId];
      } else {
        debugPrint('⚠️ [Offline] No se proporcionó ID válido para buscar avisos.');
        return [];
      }

      final queryNotices = await db.query(
        'tbAvisos',
        where: whereClause,
        whereArgs: whereArgs,
      );

      debugPrint('✅ [Offline] Avisos encontrados en DB: ${queryNotices.length}');

      final notices = queryNotices.map((row) {
        return NoticeModel(
          noticeId: row['AvisoId'] as int,
          title: row['Titulo'] as String,
          description: row['Descripcion'] as String,
          createdDate: formatDate(row['FechaCreacion'] as String),
          subjectId: row['MateriaId'] as int? ?? 0,
          groupId: row['GrupoId'] as int? ?? 0,
          teacherFullName: row['DocenteNombre'] as String?,
          startDate: row['FechaInicio'] as String?,
          endDate: row['FechaFin'] as String?,
          links: row['Enlaces'] is List ? jsonEncode(row['Enlaces']) : row['Enlaces'] as String?,
          frequencyDays: row['FrecuenciaDias'] as int? ?? 0,
        );
      }).toList();

      debugPrint('📩 Avisos offline cargados: ${notices.length}');
      return notices;

    } catch (e) {
      debugPrint('❌ Error en getNoticesOffline: $e');
      return [];
    }
  }
}
