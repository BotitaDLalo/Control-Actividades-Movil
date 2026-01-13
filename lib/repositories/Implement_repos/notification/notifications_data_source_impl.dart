
import 'package:aprende_mas/models/notice_list/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aprende_mas/config/environment/environment.dart';
import 'package:aprende_mas/repositories/Interface_repos/notification/notificactions_data_source.dart';

class NotificationsDataSourceImpl implements NotificationsDataSource {
	final Dio dio = Dio();

	@override
	Future<bool> sendNotificationToBackend(NotificationModel notification, String userId) async {
		try {
			const uri = "Notificaciones/RegistrarNotificacion";
			final data = {
				"UserId": userId,
				"MessageId": notification.messageId,
				"Title": notification.title,
				"Body": notification.body,
				"FechaRecibido": notification.sentDate
			};
			final response = await dio.post(uri, data: data);
			return response.statusCode == 200;
		} catch (e) {
			debugPrint("Error enviando notificación al backend: $e");
			return false;
		}
	}

	@override
	Future<List<NotificationModel>> fetchNotificationsFromBackend(String userId) async {
		try {
			final uri = "Notificaciones/ObtenerNotificaciones?userId=$userId";
			final response = await dio.get(uri);
			if (response.statusCode == 200 && response.data is List) {
				final List<dynamic> data = response.data;
				return data.map((e) => NotificationModel(
					messageId: e['MessageId'] ?? '',
					title: e['Title'] ?? '',
					body: e['Body'] ?? '',
					sentDate: e['FechaRecibido'] ?? '',
					data: e['Data']?.toString(),
					imageUrl: e['ImageUrl']?.toString(),
				)).toList();
			}
			return [];
		} catch (e) {
			debugPrint("Error obteniendo notificaciones del backend: $e");
			return [];
		}
    
	}
}
