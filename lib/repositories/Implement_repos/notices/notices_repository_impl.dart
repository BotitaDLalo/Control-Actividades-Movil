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

  @override
Future<List<NoticeModel>> getNotices({int? subjectId, int? groupId}) async {
  // Aquí va tu lógica para llamar a la API
  // Ejemplo:
  // final response = await api.get('/notices', queryParameters: {
  //   'subjectId': subjectId,
  //   'groupId': groupId
  // });
  // return (response.data as List).map((e) => NoticeModel.fromJson(e)).toList();
  // ⚠️ Lanzamos error intencional para activar el fallback a la base de datos local (Offline)
  throw Exception('API Online no implementada. Intentando cargar datos offline...');
}

}
