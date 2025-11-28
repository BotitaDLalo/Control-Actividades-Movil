import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_data_source.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsDataSource groupsDataSource;

  GroupsRepositoryImpl({GroupsDataSource? groupsDataSource})
      : groupsDataSource = groupsDataSource ?? GroupsDataSourceImpl();

  @override
  Future<List<Group>> getGroupsSubjects() {
    return groupsDataSource.getGroupsSubjects();
  }

  @override
  Future<List<Group>> createGroup(
      String nombreGrupo, String descripcion) {
    return groupsDataSource.createGroup(nombreGrupo, descripcion);
  }

  @override
  Future<List<Group>> createGroupSubjects(String groupName, String description,
      List<SubjectsRow> subjectsList) {
    return groupsDataSource.createGroupSubjects(
        groupName, description, subjectsList);
  }

  @override
  Future<List<GroupsCreated>> getCreatedGroups() {
    return groupsDataSource.getCreatedGroups();
  }

  @override
  Future<bool> deleteGroup(int groupId) {
    return groupsDataSource.deleteGroup(groupId);
  }

  @override
  Future<Group> updateGroup(
      int groupId, String groupName, String descriptionGroup) {
    return groupsDataSource.updateGroup(
        groupId, groupName, descriptionGroup);
  }
  
  @override
  Future<VerifyEmail> verifyEmail(String email) {
    return groupsDataSource.verifyEmail(email);
  }
  
  @override
  Future<List<StudentGroupSubject>> addStudentsGroup(int subjectId, List<String> emails) {
    return groupsDataSource.addStudentsGroup(subjectId, emails);
  }
  
  @override
  Future<List<StudentGroupSubject>> getStudentsGroup(int subjectId) {
    return groupsDataSource.getStudentsGroup(subjectId);
  }
}