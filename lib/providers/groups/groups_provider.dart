import 'package:aprende_mas/providers/activity/activity_provider.dart';
import 'package:aprende_mas/providers/groups/groups_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'groups_state.dart';

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
  final groupsRepository = GroupsRepositoryImpl();
  final activityOffline = ActivityOfflineRepositoryImpl();
  final groupsOfflineRepository = GroupsOfflineRepositoryImpl();

  final getAllActivitiesCallback =
      ref.read(activityProvider.notifier).getAllActivities;

  final getSubmissionsCallback =
      ref.read(activityProvider.notifier).getSubmissions;

  return GroupsNotifier(
      ref: ref,
      activityOffline: activityOffline,
      getAllActivitiesCallback: getAllActivitiesCallback,
      getSubmissionsCallback: getSubmissionsCallback,
      groupsRepository: groupsRepository,
      groupsOfflineRepository: groupsOfflineRepository);
});
