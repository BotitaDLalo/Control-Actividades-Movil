import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/groups/students_group_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_offline_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_repository.dart';

class StudentsGroupStateNotifier extends StateNotifier<StudentsGroupState> {
  final GroupsRepository groupsRepository;
  final GroupsOfflineRepository groupsOfflineRepository;

  StudentsGroupStateNotifier(
      {required this.groupsRepository, required this.groupsOfflineRepository})
      : super(StudentsGroupState());

  Future<VerifyEmail> verifyEmail(String email) async {
    try {
      List<VerifyEmail> lsEmails = List.from(state.lsEmails);
      bool emailExist = lsEmails.any((element) => element.email == email);
      if (!emailExist) {
        final res = await groupsRepository.verifyEmail(email);
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

  onDeleteVeryfyEmail(int index) {
    List<VerifyEmail> lsEmails = List.from(state.lsEmails);
    lsEmails.removeAt(index);
    state = state.copyWith(lsEmails: lsEmails);
  }

  clearLsEmails() {
    state = state.copyWith(lsEmails: []);
  }

  Future<bool> addStudentsGroup(int groupId) async {
    try {
      List<VerifyEmail> lsEmails = List.from(state.lsEmails);
      List<String> lsVerifiedEmails = lsEmails
          .where((element) => element.isEmailValid)
          .map((e) => e.email)
          .toList();

      final res =
          await groupsRepository.addStudentsGroup(groupId, lsVerifiedEmails);

      if (res.isNotEmpty) {
        _setAddStudentsGroup(res);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  _setAddStudentsGroup(List<StudentGroupSubject> lsStudentsGroup) {
    final lsStudentsState = List.from(state.lsStudentsGroup);
    state = state
        .copyWith(lsStudentsGroup: [...lsStudentsState, ...lsStudentsGroup]);
  }

  Future<void> removeStudentsGroup() async {}

  Future<void> getStudentsGroup(int groupId) async {
    try {
      final lsStudentsGroup = await groupsRepository.getStudentsGroup(groupId);
      _setStudentsGroup(lsStudentsGroup);
    } catch (e) {
      throw Exception(e);
    }
  }

  _setStudentsGroup(List<StudentGroupSubject> lsStudentsGroup) {
    List<StudentGroupSubject> lsStudents = List.from(state.lsStudentsGroup);
    state =
        state.copyWith(lsStudentsGroup: [...lsStudentsGroup, ...lsStudents]);
  }

Future<bool> removeStudentFromGroup({
    required int groupId,
    required int studentId,
  }) async {
    try {
      // 1. Llamada a la API
      final success = await groupsRepository.removeStudentFromGroup(
        groupId: groupId,
        studentId: studentId,
      );

      if (success) {
        // 2. Actualizar el estado local (Filtrar la lista)
        // Nota: Asegúrate de usar .alumnoId o la propiedad correcta que definimos antes
        final updatedList = state.lsStudentsGroup
            .where((student) => student.alumnoId != studentId) 
            .toList();

        // 3. Emitir nuevo estado
        state = state.copyWith(
          lsStudentsGroup: updatedList,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al eliminar alumno del grupo: $e');
      return false;
    }
  }

  void clearGroupTeacherOptionsLs() {
    state = state.copyWith(lsEmails: [], lsStudentsGroup: []);
  }
}
