import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/subjects/students_subject_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_repository.dart';
import 'package:aprende_mas/models/models.dart';

class StudentsSubjectStateNotifier extends StateNotifier<StudentsSubjectState> {
  final SubjectsRepository subjectsRepository;

  StudentsSubjectStateNotifier({required this.subjectsRepository})
      : super(StudentsSubjectState());

  onDeleteVeryfyEmail(int index) {
    List<VerifyEmail> lsEmails = List.from(state.lsEmails);
    lsEmails.removeAt(index);
    state = state.copyWith(lsEmails: lsEmails);
  }

  clearLsEmails() {
    state = state.copyWith(lsEmails: []);
  }

  Future<VerifyEmail> verifyEmail(String email) async {
    try {
      List<VerifyEmail> lsEmails = List.from(state.lsEmails);
      bool emailExist = lsEmails.any((element) => element.email == email);
      if (!emailExist) {
        final res = await subjectsRepository.verifyEmail(email);
        _setVerifyEmail(res);
        return res;
      }
      return VerifyEmail(email: '', isEmailValid: false);
    } catch (e) {
      return VerifyEmail(email: '', isEmailValid: false);
    }
  }

  _setVerifyEmail(VerifyEmail verifyEmail) {
    final lsEmails = List.from(state.lsEmails);
    state = state.copyWith(lsEmails: [verifyEmail, ...lsEmails]);
  }

  Future<bool> addStudentsSubject(int subjectId) async {
    try {
      List<VerifyEmail> lsEmails = List.from(state.lsEmails);
      List<String> lsVerifiedEmails = lsEmails
          .where((element) => element.isEmailValid)
          .map((e) => e.email)
          .toList();

      final res = await subjectsRepository.addStudentsSubject(
          subjectId, lsVerifiedEmails);

      if (res.isNotEmpty) {
        _setAddStudentsSubject(res);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  _setAddStudentsSubject(List<StudentGroupSubject> lsStudentsSubject) {
    final lsAlumnosState = List.from(state.lsStudentsSubject);
    state = state
        .copyWith(lsStudentsSubject: [...lsAlumnosState, ...lsStudentsSubject]);
  }

  Future<void> getStudentsSubject(int? groupId, int subjectId) async {
    try {
      final lsStudentsSubject =
          await subjectsRepository.getStudentsSubject(groupId, subjectId);
      _setStudentsSubject(lsStudentsSubject);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _setStudentsSubject(List<StudentGroupSubject> lsStudentsSubject) {
    List<StudentGroupSubject> lsStudents = List.from(state.lsStudentsSubject);
    state = state
        .copyWith(lsStudentsSubject: [...lsStudentsSubject, ...lsStudents]);
  }

  void clearSubjectTeacherOptionsLs() {
    state = state.copyWith(lsEmails: [], lsStudentsSubject: []);
  }
}
