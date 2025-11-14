import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notifications/firebase_cm_state_notifier.dart';
import 'package:aprende_mas/providers/notifications/firebase_cm_state.dart';
import 'package:aprende_mas/repositories/Implement_repos/notices/db_local_notifications_repository_impl.dart';

final firebasecmProvider = StateNotifierProvider<FirebasecmStateNotifier, FirebasecmState>(
  (ref) {
    final noticesRepositoryImpl = DbLocalNotificationsRepositoryImpl();

    return FirebasecmStateNotifier(noticesRepositoryImpl: noticesRepositoryImpl);
  },
);
