import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';

abstract class SubjectsRepository {
  Future<List<Subject>> getSubjectsWithoutGroup();

  Future<List<Group>> createSubjectWithGroup(String subjectName,
      String description, Color colorCode, List<int> groupsId);

  Future<List<Subject>> createSubjectWithoutGroup(
      String subjectName, String description, Color colorCode);

  Future<bool> deleteSubject(int subjectId);

  Future<void> updateSubject();

  Future<VerifyEmail> verifyEmail(String email);

  Future<List<StudentGroupSubject>> addStudentsSubject(
      int subjectId, List<String> emails);

  Future<List<StudentGroupSubject>> getStudentsSubject(int? groupId,int subjectId);
}
