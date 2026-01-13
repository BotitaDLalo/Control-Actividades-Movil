import 'package:aprende_mas/config/utils/general_utils.dart';
class NotificationModel {
  final String messageId;
  final String title;
  final String body;
  final String sentDate;
  // final Map<String, dynamic>? data;
  final String? data;
  final String? imageUrl;

  NotificationModel(
      {
      required this.messageId,
      required this.title,
      required this.body,
      required this.sentDate,
      this.data,
      this.imageUrl});

  static List<NotificationModel> noticeJsonToEntity(List<Map<String, Object?>> lsNotices) {
    List<NotificationModel> ls = lsNotices.map(
      (e) {
        return NotificationModel(
            messageId: e['MensajeId'] as String,
            title: e['Titulo'] as String,
            body: e['Descripcion'] as String,
            //sentDate: formatDate(e['FechaEnvio'] as String),
            sentDate: e['FechaEnvio'] as String,
            data: e['Data'] as String,
            imageUrl: e['ImagenURL'] as String);
      },
    ).toList();

    return ls;
  }

  static NotificationModel noticeVoid(){
    return NotificationModel(
      messageId: "",
      title: "",
      body: "",
      sentDate: "",
      data: "",
      imageUrl: ""
    );
  }

  @override
  String toString() {
    return '''
      PushMessage - $messageId
      title: $title
      body: $body
      sentDate: $sentDate
      data: $data
      imageUrl: $imageUrl
    ''';
  }
}
