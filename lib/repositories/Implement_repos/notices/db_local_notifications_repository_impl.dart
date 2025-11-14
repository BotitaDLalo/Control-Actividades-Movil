import 'package:aprende_mas/models/notice_list/notification_model.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/db_local_notifications_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/db_local_notifications_data_source.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/db_local_notifications_repository.dart';

class DbLocalNotificationsRepositoryImpl implements DbLocalNotificationsRepository {
  final DbLocalNotificationsDataSource noticesDataSource;

  DbLocalNotificationsRepositoryImpl({DbLocalNotificationsDataSource? dataSource})
      : noticesDataSource = dataSource ?? DbLocalNotificationsDataSourceImpl();

  @override
  Future<bool> storeNotification(NotificationModel notice) {
    return noticesDataSource.storeNotification(notice);
  }

  @override
  Future<List<NotificationModel>> getLsNotifications() {
    return noticesDataSource.getLsNotifications();
  }

  @override
  Future<bool> deleteNotification(String sentDate) {
    return noticesDataSource.deleteNotification(sentDate);
  }
}
