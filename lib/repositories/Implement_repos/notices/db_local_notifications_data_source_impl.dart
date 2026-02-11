import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/db_local_notifications_data_source.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class DbLocalNotificationsDataSourceImpl implements DbLocalNotificationsDataSource {
  @override
  Future<bool> storeNotification(NotificationModel notice) async {
    try {
      bool inserted = false;
      final db = await DbLocal.database;

      // Verificar si ya existe la notificación para no duplicarla
      final exists = await db.query('tbNotificaciones', where: 'MessageId = ?', whereArgs: [notice.messageId]);
      if (exists.isNotEmpty) return false;

      final query = Querys.querytbNotificacionesInsert();
      await db.transaction((txn) async {
        int idRow = await txn.rawInsert(query, [
          1, // UsuarioId (Fijo en 1 según la restricción de tbUsuarioActivo)
          notice.messageId,
          notice.title,
          notice.body,
          notice.sentDate.toString(),
          notice.notificationTypeId,
          notice.subjectId,
          notice.groupId
        ]);

        if (idRow > 0) {
          inserted = true;
        }
      });
      return inserted;
    } catch (e) {
      print(e);
      return false;
    }
  }



  @override
  Future<List<NotificationModel>> getLsNotifications() async {
    try {
      final db = await DbLocal.database;
      final ls = await db.query('tbNotificaciones', orderBy: 'FechaRecibido DESC');

      final lsNotice = NotificationModel.noticeJsonToEntity(ls);

      print('AVISO EN DATA SOURCE');
      for (var n in lsNotice) {
        print("Aviso: " + n.toString());
      }
      return lsNotice;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> deleteNotification(String sentDate) async {
    try {
      final db = await DbLocal.database;
      final query = Querys.querytbNotificacionesDeleteWhere();
      int count = await db.rawDelete(query, [sentDate]);

      if (count == 1) {
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
