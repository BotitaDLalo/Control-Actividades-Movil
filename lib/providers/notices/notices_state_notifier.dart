import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_repository.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/notices_repository_impl.dart';

import 'package:aprende_mas/repositories/Implement_repos/notices/notices_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/notices_offline_datasource_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_offline_data_source.dart';

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) => NoticesRepositoryImpl());
final noticesOfflineDatasourceProvider = Provider<NoticesOfflineDatasource>((ref) => NoticesOfflineDatasourceImpl());
final noticesOfflineRepositoryProvider = Provider<NoticesOfflineRepository>(
  (ref) => NoticesOfflineRepositoryImpl(ref.watch(noticesOfflineDatasourceProvider)),
);

final noticesProvider = StateNotifierProvider<NoticesStateNotifier, NoticesState>((ref) {
  final noticesRepository = ref.watch(noticesRepositoryProvider);
  final noticesOfflineRepository = ref.watch(noticesOfflineRepositoryProvider);
  return NoticesStateNotifier(
    noticesRepository: noticesRepository,
    noticesOfflineRepository: noticesOfflineRepository,
  );
});

class NoticesStateNotifier extends StateNotifier<NoticesState> {
  final NoticesRepository noticesRepository;
  final NoticesOfflineRepository noticesOfflineRepository;

  NoticesStateNotifier({
    required this.noticesRepository,
    required this.noticesOfflineRepository,
  }) : super(NoticesState());

  /// Obtiene los avisos, decidiendo si usar la fuente offline u online
  Future<void> getNotices({
    int? subjectId,
    int? groupId,
    bool offline = false,
  }) async {
    try {
      // 1. Indicamos que está cargando
      state = state.copyWith(isLoading: true);

      // 2. Decidimos la fuente de datos
      List<NoticeModel> notices = [];

      if (offline) {
        notices = await noticesOfflineRepository.getNoticesOffline(
          subjectId: subjectId,
          groupId: groupId,
        );
      } else {
        try {
          notices = await noticesRepository.getNotices(subjectId: subjectId, groupId: groupId);
        } catch (e) {
          debugPrint('⚠️ Error online en getNotices: $e. Intentando offline...');
          // Fallback: Si falla online, intentamos cargar offline
          notices = await noticesOfflineRepository.getNoticesOffline(subjectId: subjectId, groupId: groupId);
        }
      }

      // 3. Actualizamos el estado con la lista obtenida
      state = state.copyWith(
        lsNotices: notices,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error cargando avisos (Offline: $offline): $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Carga avisos intentando primero online, y si falla, usa offline (Ideal para estudiantes)
  Future<void> loadNotices({
    int? subjectId,
    int? groupId,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // 1. Intentar carga online
      final notices = await noticesRepository.getNotices(
        subjectId: subjectId,
        groupId: groupId,
      );
      
      state = state.copyWith(lsNotices: notices, isLoading: false);
    } catch (e) {
      debugPrint('⚠️ Error cargando avisos online: $e. Intentando offline...');
      
      // 2. Fallback a carga offline
      try {
        final notices = await noticesOfflineRepository.getNoticesOffline(
          subjectId: subjectId,
          groupId: groupId,
        );
        state = state.copyWith(lsNotices: notices, isLoading: false);
      } catch (e2) {
        debugPrint('❌ Error cargando avisos offline: $e2');
        state = state.copyWith(isLoading: false, errorMessage: e2.toString());
      }
    } finally {
      // Aseguramos que isLoading sea false al terminar todo el proceso
      if (state.isLoading) state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> createNotice(NoticeModel notice) async {
    try {
      state = state.copyWith(isLoading: true);
      List<NoticeModel> lsNotices =
          await noticesRepository.createNotice(notice);

      if (lsNotices.isNotEmpty) {
        _setNewNotice(notice);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating notice: ${e.toString()}');
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> deleteNotice(int noticeId) async {
    try {
      bool noticeDeleted = await noticesRepository.deleteNotice(noticeId);
      if (noticeDeleted) {
        // Actualizamos la lista localmente eliminando el aviso
        final updatedList = state.lsNotices
            .where((element) => element.noticeId != noticeId)
            .toList();
        state = state.copyWith(lsNotices: updatedList);
      }
      return noticeDeleted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNotice(NoticeModel notice) async {
    try {
      state = state.copyWith(isLoading: true);
      List<NoticeModel> lsNotices =
          await noticesRepository.updateNotice(notice);
      if (lsNotices.isNotEmpty) {
        // Actualizamos el aviso en la lista local
        final updatedList = state.lsNotices.map((e) {
          return e.noticeId == notice.noticeId ? notice : e;
        }).toList();
        state = state.copyWith(lsNotices: updatedList);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _setNewNotice(NoticeModel notice) {
    state = state.copyWith(lsNotices: [notice, ...state.lsNotices]);
  }
}
