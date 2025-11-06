import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/db_local_notifications_data_source.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class DbLocalNotificationsDataSourceImpl implements DbLocalNotificationsDataSource {
  @override
  Future<bool> storeNotification(NotificationModel notice) async {
    try {
      bool inserted = false;
      Database db = await DbLocal.initDatabase();
      final query = Querys.querytbNotificacionesInsert();
      await db.transaction((txn) async {
        int idRow = await txn.rawInsert(query, [
          notice.messageId,
          notice.title,
          notice.body,
          notice.sentDate.toString(),
          "",
          ""
        ]);

        if (idRow > 0) {
          inserted = true;
        }
      });
      await db.close();
      return inserted;
    } catch (e) {
      print(e);
      return false;
    }
  }



  @override
  Future<List<NotificationModel>> getLsNotifications() async {
    try {
      Database db = await DbLocal.initDatabase();
      final ls = await db.query('tbNotificaciones', orderBy: 'FechaEnvio DESC');

      final lsNotice = NotificationModel.noticeJsonToEntity(ls);

      print('AVISO EN DATA SOURCE');
      for (var n in lsNotice) {
        print("Aviso: $n");
      }
      await db.close();
      return lsNotice;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> deleteNotification(String sentDate) async {
    try {
      Database db = await DbLocal.initDatabase();
      final query = Querys.querytbNotificacionesDeleteWhere();
      int count = await db.rawDelete(query, [sentDate]);

      await db.close();
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
