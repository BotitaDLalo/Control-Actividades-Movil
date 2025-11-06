import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/students_group_state.dart';
import 'package:aprende_mas/providers/groups/students_group_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_repository_impl.dart';

final studentsGroupProvider = StateNotifierProvider<
    StudentsGroupStateNotifier, StudentsGroupState>(
  (ref) {
    final groupsRepository = GroupsRepositoryImpl();
    final groupsOfflineRepository = GroupsOfflineRepositoryImpl();
    return StudentsGroupStateNotifier(
        groupsRepository: groupsRepository,
        groupsOfflineRepository: groupsOfflineRepository);
  },
);