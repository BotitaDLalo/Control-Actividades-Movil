import 'package:aprende_mas/config/utils/general_utils.dart';
class NotificationModel {
  final String messageId;
  final String title;
  final String body;
  final String sentDate;
  // final Map<String, dynamic>? data;
  final int notificationTypeId;
  final int? subjectId;
  final int? groupId;
  final String? data;
  final String? imageUrl;

  NotificationModel(
      {
      required this.messageId,
      required this.title,
      required this.body,
      required this.sentDate,
      required this.notificationTypeId,
      this.subjectId,
      this.groupId,
      this.data,
      this.imageUrl});

  static List<NotificationModel> noticeJsonToEntity(List<Map<String, Object?>> lsNotices) {
    List<NotificationModel> ls = lsNotices.map(
      (e) {
        return NotificationModel(
            messageId: e['MessageId'] as String,
            title: e['Titulo'] as String,
            body: e['Cuerpo'] as String,
            sentDate: e['FechaRecibido'] as String,
            notificationTypeId: e['TipoNotificacionId'] as int,
            subjectId: e['MateriaId'] as int?,
            groupId: e['GrupoId'] as int?,
            data: null,
            imageUrl: null);
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
      notificationTypeId: 0,
      subjectId: null,
      groupId: null,
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
      notificationTypeId: $notificationTypeId
      subjectId: $subjectId
      groupId: $groupId
      data: $data
      imageUrl: $imageUrl
    ''';
  }
}
