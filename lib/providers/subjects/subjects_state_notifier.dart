import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/subjects/subjects_state.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_repository.dart';

class SubjectsStateNotifier extends StateNotifier<SubjectsState> {
  Function(int) getAllActivitiesCallback;
  Function(int) getSubmissionsCallback;
  final SubjectsRepository subjectsRepository;
  final SubjectsOfflineRepositoryImpl subjectsOffline;
  final ActivityOfflineRepositoryImpl activityOffline;
  final Ref ref;

  SubjectsStateNotifier(this.ref,
      {required this.subjectsRepository,
      required this.getAllActivitiesCallback,
      required this.getSubmissionsCallback,
      required this.subjectsOffline,
      required this.activityOffline})
      : super(SubjectsState());

  Future<void> getSubjects() async {
    try {
      final subjects = await subjectsRepository.getSubjectsWithoutGroup();
      debugPrint("SubjectsStateNotifier: $subjects");
      if (mounted) {
        setSubjects(subjects);
      }
    } catch (e, stacktrace) {
      debugPrint("Error en getSubjects: $e");
      debugPrint("Stacktrace: $stacktrace");
      throw Exception(e);
    }
  }

  Future<List<Subject>> getSubjectsWithoutGroup() async {
    try {
      List<Subject> lsSubjects = List.from(state.lsSubjects);
      return lsSubjects;
    } catch (e) {
      return [];
    }
  }

  setSubjects(List<Subject> subjects) {
    state = state.copyWith(lsSubjects: subjects);
  }

  Future<void> createSubjectWithGroups(String subjectName, String description,
      Color colorCode, List<int> groupsId) async {
    try {
      final subject = await subjectsRepository.createSubjectWithGroup(
          subjectName, description, colorCode, groupsId);
      _setSubjectWithGroups(subject);
    } catch (e) {
      throw Exception(e);
    }
  }

  _setSubjectWithGroups(List<Group> groups) {
    final groupsNotifier = ref.read(groupsProvider.notifier);
    groupsNotifier.onNewSubject(groups);
  }

  Future<void> createSubjectWithoutGroup(
      String subjectName, String description, Color colorCode) async {
    try {
      final subjects = await subjectsRepository.createSubjectWithoutGroup(
          subjectName, description, colorCode);
      _setSubjectsWithoutGroups(subjects);
    } catch (e) {
      throw Exception(e);
    }
  }

  _setSubjectsWithoutGroups(List<Subject> subjects) {
    state = state.copyWith(lsSubjects: subjects);
  }

  void addSubjectToState(Subject subject) async {
    final subjectId = subject.materiaId;
    state = state.copyWith(lsSubjects: [subject, ...state.lsSubjects]);

    List<Subject> lsSubject = [subject];
    await subjectsOffline.saveSubjectsWithoutGroup(lsSubject);

    await getAllActivitiesCallback(subjectId);

    for (var act in subject.actividades ?? []) {
      final activity = act as Activity;
      final activityId = activity.activityId;
      List<Submission> lsSubmissions = await getSubmissionsCallback(activityId!);
      await activityOffline.saveSubmissions(lsSubmissions, activityId);
    }
  }

  Future<bool> deleteSubject(int subjectId) async {
    try {
      debugPrint("🗑️ Iniciando eliminación de materia ID: $subjectId");
      bool success = await subjectsRepository.deleteSubject(subjectId);
      if (success) {
        debugPrint("✅ Materia eliminada del backend, actualizando state");
        _deleteSubjectFromState(subjectId);
        debugPrint("✅ Materia removida del state local");
        return true;
      } else {
        debugPrint("❌ El backend reportó fallo en eliminación de materia");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error inesperado al eliminar materia: $e");
      return false;
    }
  }

  void _deleteSubjectFromState(int subjectId) {
    List<Subject> lsSubjects = List.from(state.lsSubjects);
    lsSubjects.removeWhere((subject) => subject.materiaId == subjectId);
    state = state.copyWith(lsSubjects: lsSubjects);
  }

  void clearSubjectsState() {
    state = SubjectsState();
  }
}
