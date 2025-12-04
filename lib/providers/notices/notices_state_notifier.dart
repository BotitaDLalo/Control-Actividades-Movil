import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_repository.dart';

class NoticesStateNotifier extends StateNotifier<NoticesState> {
  final NoticesRepository noticesRepository;

  NoticesStateNotifier({required this.noticesRepository})
      : super(NoticesState());

  Future<bool> createNotice(NoticeModel notice) async {
    try {
      List<NoticeModel> lsNotices =
          await noticesRepository.createNotice(notice);

      if (lsNotices.isNotEmpty) {
        _setNewNotice(notice);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating notice: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteNotice(int notice) async {
    try {
      bool noticeDeleted = await noticesRepository.deleteNotice(notice);
      return noticeDeleted;
    } catch (e) {
      return false;
    }
  }

  // Future<List<NoticeModel>> getlsNotices(NoticeModel notice) async {
  //   try {
  //     List<NoticeModel> lsNotices =
  //         await noticesRepository.getlsNotices(notice);

  //     _setlsNotices(lsNotices);
  //     return lsNotices;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return [];
  //   }
  // }
  // _setlsNotices(List<NoticeModel> lsNotices) {}
  Future<bool> updateNotice(NoticeModel notice) async {
    try {
      List<NoticeModel> lsNotices = await noticesRepository.updateNotice(notice);
      if (lsNotices.isNotEmpty) {
        // En una app real, aquí actualizarías el listado principal, pero por ahora 
        // solo retornamos true si el backend tuvo éxito.
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
  void _setNewNotice(NoticeModel notice) {
    state = state.copyWith(lsNotices: [notice, ...state.lsNotices]);
  }
}
