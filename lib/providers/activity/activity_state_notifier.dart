import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_repository.dart';
import 'package:aprende_mas/models/activities/activity/activity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_data_source_impl.dart';

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
      _setActivities(activities, subjectId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      // Re-throw para que auth_state_notifier pueda capturar el error
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }


  Future<void> getAllActivitiesOffline(int subjectId) async {
    try {
      state = state.copyWith(isLoading: true);
      final lsActivities =
          await activityOfflineRepository.getAllActivitiesOffline(subjectId);
      _setActivities(lsActivities, subjectId);
      debugPrint("Actividades cargadas desde offline: ${lsActivities.map((a) => {'id': a.activityId, 'nombre': a.nombreActividad}).toList()}");
    } catch (e) {
      debugPrint(e.toString());
      // Re-throw para que auth_state_notifier pueda capturar el error
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

    Future<void> loadActivities(int subjectId) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // 1. Intenta obtener las actividades frescas desde el repositorio online
      final activities = await activityRepository.getAllActivities(subjectId);
      
      // Si tiene éxito, actualiza el estado y guarda los datos en la BD local
      _setActivities(activities, subjectId);
      // TODO: La lógica para guardar/actualizar actividades en la BD local debe ser implementada aquí
      // para que los datos estén disponibles en modo offline la próxima vez.
      

    } catch (e) {
      // 2. Si la carga online falla, intenta cargar desde la base de datos local
      debugPrint("Fallo en carga online de actividades, usando fallback offline. Error: $e");
      try {
        final offlineActivities = await activityOfflineRepository.getAllActivitiesOffline(subjectId);
        debugPrint("Cargando desde offline: ${offlineActivities.map((a) => {'id': a.activityId, 'nombre': a.nombreActividad}).toList()}");
        _setActivities(offlineActivities, subjectId);
      } catch (e2) {
        // 3. Si la carga offline también falla, se informa el error original.
        debugPrint("Error en carga offline de actividades: $e2");
        state = state.copyWith(errorMessage: e.toString());
      }
    } finally {
      // 4. Se asegura de que el indicador de carga siempre se desactive.
      state = state.copyWith(isLoading: false);
    }
  }

void _setActivities(List<Activity> newActivitiesForSubject, int subjectId) {
  // 1. Hacemos una copia de la lista actual para poder modificarla.
  final currentGlobalActivities = List<Activity>.from(state.lsActivities);

  // 2. Eliminamos de la lista global todas las actividades que pertenecen a la materia que estamos actualizando.
  currentGlobalActivities.removeWhere((activity) => activity.materiaId == subjectId);

  // 3. Agregamos las nuevas actividades (recién obtenidas) a la lista global.
  currentGlobalActivities.addAll(newActivitiesForSubject);

  // 4. Actualizamos el estado con la lista combinada y actualizada.
  state = state.copyWith(lsActivities: currentGlobalActivities);
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
  int materiaId,
  {bool permitirEntregasTarde = false, bool tieneLimiteEntregas = false, int limiteEntregasPorAlumno = 0}
) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final updatedActivity = await activityRepository.updateActivity(
          activityId, nombre, descripcion, fechaLimite, puntaje, materiaId,
          permitirEntregasTarde: permitirEntregasTarde,
          tieneLimiteEntregas: tieneLimiteEntregas,
          limiteEntregasPorAlumno: limiteEntregasPorAlumno);

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

  Future<bool> sendSubmission(int activityId, String answer, {List<String> links = const []}) async {
    try {
      final success = await activityRepository.sendSubmission(activityId, answer, links: links);
      if (success) return true;
      return await _fallbackToOffline(activityId, answer, links: links);
    } on SubmissionException {
      rethrow;
    } catch (e) {
      return await _fallbackToOffline(activityId, answer, links: links);
    }
  }

  Future<bool> sendSubmissionWithLinks(int activityId, String answer, List<String> links) async {
    try {
      final result = await activityRepository.sendSubmission(activityId, answer, links: links);
      if (result == true) return true;
      return await _fallbackToOffline(activityId, answer, links: links);
    } on SubmissionException {
      rethrow;
    } catch (e) {
      debugPrint("Error en sendSubmissionWithLinks: $e");
      return await _fallbackToOffline(activityId, answer, links: links);
    }
  }

  Future<bool> sendSubmissionWithFiles(int activityId, String answer, List<String> fileUrls) async {
    try {
      final success = await activityRepository.sendSubmission(activityId, answer, files: fileUrls);
      if (success) return true;
      return await _fallbackToOffline(activityId, answer, files: fileUrls);
    } on SubmissionException {
      rethrow;
    } catch (e) {
      debugPrint("Error en sendSubmissionWithFiles: $e");
      return await _fallbackToOffline(activityId, answer, files: fileUrls);
    }
  }

  Future<bool> sendSubmissionWithFilesAndLinks(int activityId, String answer, List<String> fileUrls, List<String> links) async {
    try {
      final success = await activityRepository.sendSubmission(activityId, answer, links: links, files: fileUrls);
      if (success) return true;
      return await _fallbackToOffline(activityId, answer, links: links, files: fileUrls);
    } on SubmissionException {
      rethrow;
    } catch (e) {
      debugPrint("Error en sendSubmissionWithFilesAndLinks: $e");
      return await _fallbackToOffline(activityId, answer, links: links, files: fileUrls);
    }
  }

  Future<bool> _fallbackToOffline(int activityId, String answer,
      {List<String>? links, List<String>? files}) async {
    final hasInternet = await ConnectivityCheck.checkInternetConnectivity();
    if (!hasInternet) {
      String offlineAnswer = answer;
      if (links != null && links.isNotEmpty) {
        offlineAnswer += "\n\n[Enlaces pendientes]:\n${links.join('\n')}";
      }
      if (files != null && files.isNotEmpty) {
        offlineAnswer += "\n\n[Archivos adjuntos]:\n${files.join('\n')}";
      }
      return await sendSubmissionOffline(activityId, offlineAnswer);
    }
    return false;
  }

  Future<String> uploadFile(PlatformFile file, int activityId, int studentId) async {
    try {
      return await activityRepository.uploadFile(file, activityId, studentId);
    } catch (e) {
      debugPrint("Error en uploadFile: $e");
      rethrow;
    }
  }

  Future<bool> cancelSubmission(int studentActivityId, int activityId) async {
    try {
      final success = await activityRepository.cancelSubmission(studentActivityId, activityId);
      
      if (success) {
        // Actualizar lista local - remover el submission cancelado
        List<Submission> lsSubmissionsState = List.from(state.lsSubmissions);
        List<Submission> lsSubmissions = lsSubmissionsState
            .where((element) => element.submissionActivityStudentId != studentActivityId)
            .toList();
        _updateLsSubmissions(lsSubmissions);
      }
      
      return success;
    } catch (e) {
      debugPrint('Error en cancelSubmission: $e');
      return false;
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

  void setSubmissionGrade(double grade) {
    state = state.copyWith(grade: grade);
  }

  Future<bool> submissionGrading(
      {required int submissionId, required double grade}) async {
    try {
      final res =
          await activityRepository.submissionGrading(submissionId, grade);
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeGrade(int submissionId) async {
    try {
      final res = await activityRepository.removeGrade(submissionId);
      if (res) {
        state = state.copyWith(grade: 0);
      }
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
