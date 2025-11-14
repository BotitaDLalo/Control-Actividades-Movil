import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/services/services.dart';
import 'package:aprende_mas/providers/notifications/firebase_cm_state.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/db_local_notifications_repository_impl.dart';

class FirebasecmStateNotifier extends StateNotifier<FirebasecmState> {
  final DbLocalNotificationsRepositoryImpl noticesRepositoryImpl;

  FirebasecmStateNotifier({required this.noticesRepositoryImpl})
      : super(FirebasecmState());

  void onRequestPermissions() async {
    NotificationSettings settings =
        await FirebaseCMConfiguration.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      _setPermissionsChanged(settings.authorizationStatus);
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }
  }

  _setPermissionsChanged(AuthorizationStatus status) {
    state = state.copyWith(status: AuthorizationStatus.authorized);
  }

  // onNewNotice(Notice notice) {
  //   List<Notice> lsNotices = List.from(state.notices);
  //   state = state.copyWith(notices: [notice, ...lsNotices]);
  // }

  // void onLoadNotifications() async {
  //   List<Notice> lsNotices = await noticesRepositoryImpl.getLsNotifications();
  //   state = state.copyWith(notifications: lsNotices);
  // }
}
