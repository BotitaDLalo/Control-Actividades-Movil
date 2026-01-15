import 'package:aprende_mas/config/services/google/google_signin_api_impl.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/authentication/auth_state_notifier.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/authentication/auth_user_offline_repository_impl.dart';
import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_respository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/Implement_repos/authentication/auth_repository_impl.dart';

final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authStateRepository = AuthRepositoryImpl();

  final keyValueStorageService = KeyValueStorageServiceImpl();
  final googleSigninApi = GoogleSigninApiImpl();

  final authUserOffline = AuthUserOfflineRepositoryImpl();

  final groups = GroupsRepositoryImpl();
  final groupsOffline = GroupsOfflineRepositoryImpl();

  final subjects = SubjectsRespositoryImpl();
  final subjectsOffline = SubjectsOfflineRepositoryImpl();

  final activityOffline = ActivityOfflineRepositoryImpl();

  final setGroupsSubjectsState =
      ref.read(groupsProvider.notifier).setGroupsSubjects;

  final setSubjectsWithoutGroup =
      ref.read(subjectsProvider.notifier).setSubjects;

  final getAllActivitiesCallback =
      ref.read(activityProvider.notifier).getAllActivities;

  final getAllActivitiesOfflineCallback =
      ref.read(activityProvider.notifier).getAllActivitiesOffline;

  final getSubmissionsCallback =
      ref.read(activityProvider.notifier).getSubmissions;

  final getSubmissionOfflineCallback =
      ref.read(activityProvider.notifier).getSubmissionsOffline;

  final getGroupsSubjectsCallback =
      ref.read(groupsProvider.notifier).getGroupsSubjects;

  final getGroupsSubjectsOfflineCallback =
      ref.read(groupsProvider.notifier).getGroupsSubjectsOffile;

  final sendSubmissionsCallback =
      ref.read(activityProvider.notifier).sendSubmission;

  final catalogNamesCallback = ref.read(catalogNamesProvider);

  return AuthStateNotifier(
      setSubjectsWithoutGroupState: setSubjectsWithoutGroup,
      authUserOffline: authUserOffline,
      authRepository: authStateRepository,
      storageService: keyValueStorageService,
      googleSigninApi: googleSigninApi,
      getSubmissionsCallback: getSubmissionsCallback,
      setGroupsSubjectsState: setGroupsSubjectsState,
      getAllActivitiesCallback: getAllActivitiesCallback,
      getSubmissionsOfflineCallback: getSubmissionOfflineCallback,
      getAllActivitiesOfflineCallback: getAllActivitiesOfflineCallback,
      getGroupsSubjectsCallback: getGroupsSubjectsCallback,
      getGroupsSubjectsOfflineCallback: getGroupsSubjectsOfflineCallback,
      activityOffline: activityOffline,
      groups: groups,
      subjects: subjects,
      groupsOffline: groupsOffline,
      subjectsOffline: subjectsOffline,
      sendSubmission: sendSubmissionsCallback,
      cn: catalogNamesCallback);
});
