import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_repository.dart';

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivityRepository activityRepository;
  final ActivityOfflineRepository activityOfflineRepository;

  ActivityNotifier({
    required this.activityRepository,
    required this.activityOfflineRepository,
  }) : super(ActivityState());

  void errorMessage(String errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  List<Activity> getActivitiesBySubject(int subjectId, List<Activity> lsActivities) {
    try {
      final lsActivitiesBySubject =
          Activity.activitiesBySubject(lsActivities, subjectId);
      return lsActivitiesBySubject;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> getAllActivities(int subjectId) async {
    try {
      state = state.copyWith(isLoading: true);
      final activities = await activityRepository.getAllActivities(subjectId);
      _setActivities(activities);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }


  Future<void> getAllActivitiesOffline(int subjectId) async {
    try {
      state = state.copyWith(isLoading: true);
      final lsActivities =
          await activityOfflineRepository.getAllActivitiesOffline(subjectId);
      _setActivities(lsActivities);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

void _setActivities(List<Activity> activities) {
  if (activities.isNotEmpty) {
    List<Activity> lsActivities = List.from(state.lsActivities);

    List<Activity> newActivities = activities.where((newActivity) {
      return !lsActivities.any((existingActivity) => existingActivity.activityId == newActivity.activityId);
    }).toList();

    if (newActivities.isNotEmpty) {
      state = state.copyWith(lsActivities: [...newActivities, ...lsActivities]);
    }
  }
}


Future<bool> createdActivity(Map<String, dynamic> activityLike) async {
  try {
    final activity = await activityRepository.createdActivity(activityLike);
     print("Actividad creada: $activity");
    _setCreatedActivity(activity);
    // await getAllActivities(activityLike['materiaId']);
    return true;
  } catch (e) {
    state = state.copyWith(errorMessage: e.toString());
    return false;
  } finally {
    state = state.copyWith(isLoading: false);
  }
}

void _setCreatedActivity(Activity activity) {
  // Actualizamos el estado con la nueva actividad
  List<Activity> updatedList = List.from(state.lsActivities)..add(activity);
  print("Actividades antes de actualizar: ${state.lsActivities.length}");
  state = state.copyWith(lsActivities: updatedList);
  print("Actividades después de agregar nueva: ${updatedList.length}");
}

  // Future<bool> createdActivity(int materiaId, String nombreActividad,
  //     String descripcion, DateTime fechaLimite, int puntaje) async {
  //   try {
  //     state = state.copyWith(isLoading: true); // Indicando que está cargando
  //     final activity = await activityRepository.createdActivity(
  //         materiaId, nombreActividad, descripcion, fechaLimite, puntaje);

  //     if (activity.isNotEmpty) {
  //       _setCreatedActivity(activity);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     state = state.copyWith(errorMessage: e.toString());
  //     return false;
  //   } finally {
  //     state =
  //         state.copyWith(isLoading: false); // Indicando que terminó la carga
  //   }
  // }

  // void _setCreatedActivity(List<Activity> activity) {
  //   state = state.copyWith(lsActivities: activity);
  // }

Future<void> updateActivity(
  int activityId, 
  String nombre, 
  String descripcion, 
  DateTime fechaLimite, 
  int puntaje, 
  int materiaId) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final updatedActivity = await activityRepository.updateActivity(
          activityId, nombre, descripcion, fechaLimite, puntaje, materiaId);

// 2. IMPORTANTE: Actualizamos la lista localmente AQUÍ MISMO
      _updateActivityInState(updatedActivity);

    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      throw Exception("Error updating activity: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // --- AGREGA ESTA FUNCIÓN PRIVADA EN TU CLASE ActivityNotifier ---
  void _updateActivityInState(Activity updatedActivity) {
    // 1. Hacemos una copia de la lista actual para poder modificarla
    List<Activity> currentList = List.from(state.lsActivities);
    
    // 2. Buscamos la actividad vieja usando el ID
    final index = currentList.indexWhere((a) => a.activityId == updatedActivity.activityId);
    
    if (index != -1) {
      // 3. La reemplazamos por la nueva que vino del servidor
      currentList[index] = updatedActivity;
      
      // 4. Actualizamos el estado. ¡Esto refresca la pantalla instantáneamente!
      state = state.copyWith(lsActivities: currentList);
    }
  }

  Future<void> deleteActivity(int activityId) async {
    try {
      await activityRepository.deleteActivity(activityId);
      _deleteActivityInState(activityId);
    } on UncontrolledError catch (e) {
      errorMessage(e.message);
    }
  }

  _deleteActivityInState(int activityId) {
    List<Activity> lsActivitiesFromState = List.from(state.lsActivities);
    final lsActivities = lsActivitiesFromState
        .where(
          (activity) => activity.activityId != activityId,
        )
        .toList();

    state = state.copyWith(lsActivities: lsActivities);
  }

  Future<List<Submission>> getSubmissions(int activityId) async {
    try {
      final lsSubmisions = await activityRepository.getSubmissions(activityId);
      _setLsSubmissions(lsSubmisions);
      return lsSubmisions;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> sendSubmission(int activityId, String answer) async {
    try {
      final submissionSent =
          await activityRepository.sendSubmission(activityId, answer);
      if (submissionSent.isNotEmpty) {
        _setLsSubmissions(submissionSent);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> cancelSubmission(int studentActivityId, int activityId) async {
    try {
      List<Submission> lsSubmissionsState = List.from(state.lsSubmissions);

      await activityRepository.cancelSubmission(studentActivityId, activityId);

      List<Submission> lsSubmissions = lsSubmissionsState
          .where((element) => element.studentActivityId != studentActivityId)
          .toList();
      _updateLsSubmissions(lsSubmissions);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> sendSubmissionOffline(int activityId, String answer) async {
    try {
      final submissionSent = await activityOfflineRepository
          .sendSubmissionOffline(activityId, answer);
      if (submissionSent.isNotEmpty) {
        _setLsSubmissions(submissionSent);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Submission>> getSubmissionsOffline(int activityId) async {
    try {
      final lsSubmissions =
          await activityOfflineRepository.getSubmissionsOffline(activityId);
      _setLsSubmissions(lsSubmissions);
      return lsSubmissions;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  void _updateLsSubmissions(List<Submission> lsSubmisions) {
    state = state.copyWith(lsSubmissions: lsSubmisions);
  }

  void _setLsSubmissions(List<Submission> lsSubmisions) {
    List<Submission> lsSubmisionsState = List.from(state.lsSubmissions);
    state =
        state.copyWith(lsSubmissions: [...lsSubmisionsState, ...lsSubmisions]);
  }

  void setSubmissionGrade(int grade) {
    state = state.copyWith(grade: grade);
  }

  Future<bool> submissionGrading(
      {required int submissionId, required int grade}) async {
    try {
      final res =
          await activityRepository.submissionGrading(submissionId, grade);
      return res;
    } catch (e) {
      return false;
    }
  }

  void clearActivityState() {
    state = ActivityState();
  }

  void clearSubmissionData() {
    state = state.copyWith(grade: 0);
  }
}
