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
      debugPrint("SubjectsStateNotifier: ${subjects.map((s) => {'id': s.materiaId, 'desc': s.descripcion, 'code': s.codigoAcceso}).toList()}");
      if (mounted) {
        setSubjects(subjects);
        await subjectsOffline.saveSubjectsWithoutGroup(subjects);
      }
    } catch (e, stacktrace) {
      debugPrint("Error en getSubjects online: $e");
      debugPrint("Stacktrace: $stacktrace");
      // Fallback a offline
      try {
        final subjectsOfflineList = await subjectsOffline.getSujectsWithoutGroup();
        debugPrint("Cargando desde offline: ${subjectsOfflineList.map((s) => {'id': s.materiaId, 'desc': s.descripcion, 'code': s.codigoAcceso}).toList()}");
        if (mounted) {
          setSubjects(subjectsOfflineList);
        }
      } catch (e2) {
        debugPrint("Error en offline: $e2");
        // No hacer nada
      }
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
      debugPrint("📝 Llamando createSubjectWithGroups: $subjectName, grupos: $groupsId");
      final subject = await subjectsRepository.createSubjectWithGroup(
          subjectName, description, colorCode, groupsId);
      debugPrint("📝 Materia creada, actualizando groups");
      _setSubjectWithGroups(subject);
      debugPrint("📝 Groups actualizados con nueva materia");
    } catch (e) {
      debugPrint("❌ Error en createSubjectWithGroups: $e");
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
      await subjectsOffline.saveSubjectsWithoutGroup(subjects);
    } catch (e) {
      throw Exception(e);
    }
  }

  _setSubjectsWithoutGroups(List<Subject> subjects) {
    state = state.copyWith(lsSubjects: subjects);
  }

  void addSubjectToState(Subject subject) async {
    final subjectId = subject.materiaId;

    // Verificar si la materia ya existe en el estado
    final existingSubjectIndex = state.lsSubjects.indexWhere((s) => s.materiaId == subjectId);

    if (existingSubjectIndex != -1) {
      // La materia ya existe, no la agregamos de nuevo
      debugPrint("⚠️ Materia ID $subjectId ya existe en el estado, omitiendo duplicado");
      return;
    }

    // La materia no existe, la agregamos
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

  Future<bool> updateSubject(int subjectId, String name, String description) async {
    try {
      debugPrint("🖊️ Iniciando actualización de materia ID: $subjectId");
      final updatedSubject = await subjectsRepository.updateSubject(subjectId, name, description);
      if (updatedSubject != null) {
        _updateSubjectInState(updatedSubject);
        debugPrint("✅ Materia actualizada en state local");
        return true;
      } else {
        debugPrint("❌ El backend no retornó la materia actualizada");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error inesperado al actualizar materia: $e");
      return false;
    }
  }

  void _updateSubjectInState(Subject updatedSubject) {
    List<Subject> lsSubjects = List.from(state.lsSubjects);
    final index = lsSubjects.indexWhere((s) => s.materiaId == updatedSubject.materiaId);
    if (index != -1) {
      lsSubjects[index] = updatedSubject;
      state = state.copyWith(lsSubjects: lsSubjects);
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
