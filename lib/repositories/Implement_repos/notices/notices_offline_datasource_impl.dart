import 'package:aprende_mas/models/notice_list/notice_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_data_source.dart';
import 'package:aprende_mas/config/data/db_local.dart';
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
      if (groupId != null) {
        whereClause = 'GrupoId = ?';
        whereArgs = [groupId];
      }
      // 📘 Avisos por materia (Si no hay grupo, buscamos generales de la materia)
      else {
        whereClause = 'MateriaId = ? AND GrupoId IS NULL';
        whereArgs = [subjectId];
      }

      final queryNotices = await db.query(
        'tbAvisos',
        where: whereClause,
        whereArgs: whereArgs,
      );

      final notices = queryNotices.map((row) {
        return NoticeModel(
          noticeId: row['AvisoId'] as int,
          title: row['Titulo'] as String,
          description: row['Descripcion'] as String,
          createdDate: formatDate(row['FechaCreacion'] as String),
          subjectId: row['MateriaId'] as int? ?? 0,
          groupId: row['GrupoId'] as int? ?? 0,
          teacherFullName: row['DocenteNombre'] as String?,
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
