import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activity_state.dart';
import 'package:aprende_mas/providers/activity/activity_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_repository_impl.dart';

final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  return ActivityRepositoryImpl();
});

final activityOfflineRepositoryProvider = Provider<ActivityOfflineRepositoryImpl>(
    (ref) => ActivityOfflineRepositoryImpl());

final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
      
  final activityRepository = ref.watch(activityRepositoryProvider);
  final activityOfflineRepository = ref.watch(activityOfflineRepositoryProvider);

  return ActivityNotifier(
    activityOfflineRepository: activityOfflineRepository,
    activityRepository: activityRepository,
    // activityOfflineRepository: activityOfflineRepository
  );
});
