import 'package:aprende_mas/models/models.dart';

abstract class NoticesRepository {
  Future<List<NoticeModel>> createNotice(NoticeModel notice);
  Future<List<NoticeModel>> getlsNotices(NoticeModel notice);
  Future<bool> deleteNotice(int notice);
  Future<List<NoticeModel>> updateNotice(NoticeModel notice);
}
