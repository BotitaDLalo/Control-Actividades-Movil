import 'package:aprende_mas/models/notice_list/notice_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_data_source.dart';

class NoticesOfflineRepositoryImpl implements NoticesOfflineRepository {

  final NoticesOfflineDatasource datasource;

  NoticesOfflineRepositoryImpl(this.datasource);

  @override
  Future<List<NoticeModel>> getNoticesOffline({
    int? subjectId,
    int? groupId,
  }) async {
    return await datasource.getNoticesOffline(
      subjectId: subjectId,
      groupId: groupId,
    );
  }
}
