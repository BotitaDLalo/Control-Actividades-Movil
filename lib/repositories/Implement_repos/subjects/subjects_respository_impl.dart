import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_data_source.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_repository.dart';

class SubjectsRespositoryImpl implements SubjectsRepository {
  SubjectsDataSource subjectsDataSource;

  SubjectsRespositoryImpl({SubjectsDataSource? subjectsDataSource})
      : subjectsDataSource = subjectsDataSource ?? SubjectsDataSourceImpl();

  @override
  Future<List<Group>> createSubjectWithGroup(String subjectName,
      String description, Color colorCode, List<int> groupsId) {
    return subjectsDataSource.createSubjectWithGroup(
        subjectName, description, colorCode, groupsId);
  }

  @override
  Future<List<Subject>> createSubjectWithoutGroup(
      String subjectName, String description, Color colorCode) {
    return subjectsDataSource.createSubjectWithoutGroup(
        subjectName, description, colorCode);
  }

  @override
  Future<void> deleteSubject() {
    // TODO: implement deleteSubject
    throw UnimplementedError();
  }

  @override
  Future<void> updateSubject() {
    // TODO: implement updateSubject
    throw UnimplementedError();
  }

  @override
  Future<List<Subject>> getSubjectsWithoutGroup() {
    debugPrint("SubjectsRespositoryImpl: ${subjectsDataSource}");
    return subjectsDataSource.getSubjectsWithoutGroup();
  }

  @override
  Future<List<StudentGroupSubject>> getStudentsSubject(int? groupId, int subjectId) {
    return subjectsDataSource.getStudentsSubject(groupId, subjectId);
  }

  @override
  Future<VerifyEmail> verifyEmail(String email) {
    return subjectsDataSource.verifyEmail(email);
  }

  @override
  // Future<List<StudentGroupSubject>> addStudentsSubject(int? groupId, int subjectId, List<String> emails) {
  Future<List<StudentGroupSubject>> addStudentsSubject(
      int subjectId, List<String> emails) {
    return subjectsDataSource.addStudentsSubject(subjectId, emails);
  }

  @override
  Future<bool> removeStudent({required int subjectId, required int studentId}) {
    // Delega la llamada a la capa de DataSource
    return subjectsDataSource.removeStudent(
      subjectId: subjectId,
      studentId: studentId,
    );
  }

}
