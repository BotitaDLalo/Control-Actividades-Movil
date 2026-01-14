
import 'package:aprende_mas/models/notice_list/notification_model.dart';

abstract class NotificationsDataSource {
	Future<bool> sendNotificationToBackend(NotificationModel notification, String userId);

	Future<List<NotificationModel>> fetchNotificationsFromBackend(String userId);
}
