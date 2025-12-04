import 'package:aprende_mas/models/notice_list/notice_model.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/notices_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_data_source.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_repository.dart';

class NoticesRepositoryImpl implements NoticesRepository {
  final NoticesDataSource noticesDataSource;

  NoticesRepositoryImpl({NoticesDataSource? noticesDataSource})
      : noticesDataSource = noticesDataSource ?? NoticesDataSourceImpl();

  @override
  Future<List<NoticeModel>> createNotice(NoticeModel notice) {
    return noticesDataSource.createNotice(notice);
  }

  @override
  Future<List<NoticeModel>> getlsNotices(NoticeModel notice) {
    return noticesDataSource.getlsNotices(notice);
  }
  
  @override
  Future<bool> deleteNotice(int notice) {
    return noticesDataSource.deleteNotice(notice);
  }

  @override
  Future<List<NoticeModel>> updateNotice(NoticeModel notice) {
    return noticesDataSource.updateNotice(notice);
  }
}
