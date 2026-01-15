import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notifications/notifications_state_notifier.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/db_local_notifications_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/notification/notifications_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/notification/notifications_data_source_impl.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsStateNotifier, List<NotificationModel>>(
  (ref) {
    final dbLocalNoticesRepository = DbLocalNotificationsRepositoryImpl();
    final remoteRepository = NotificationsRepositoryImpl(
      dataSource: NotificationsDataSourceImpl(),
    );
    return NotificationsStateNotifier(
      dbLocalNoticesRepository: dbLocalNoticesRepository,
      remoteRepository: remoteRepository,
    );
  },
);
