
import 'package:aprende_mas/models/notice_list/notification_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/notification/notifications_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/notification/notificactions_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
	final NotificationsDataSource dataSource;

	NotificationsRepositoryImpl({required this.dataSource});

	@override
	Future<bool> sendNotificationToBackend(NotificationModel notification, String userId) {
		return dataSource.sendNotificationToBackend(notification, userId);
	}

	@override
	Future<List<NotificationModel>> fetchNotificationsFromBackend(String userId) {
		return dataSource.fetchNotificationsFromBackend(userId);
	}
}
