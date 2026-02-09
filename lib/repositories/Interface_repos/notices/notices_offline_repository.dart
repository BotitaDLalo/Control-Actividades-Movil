import 'package:aprende_mas/models/notice_list/notice_model.dart';

abstract class NoticesOfflineRepository {
  Future<List<NoticeModel>> getNoticesOffline({
    int? subjectId,
    int? groupId,
  });
}
