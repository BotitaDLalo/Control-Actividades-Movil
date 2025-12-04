import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activity_state.dart';
import 'package:aprende_mas/providers/activity/activity_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_repository_impl.dart';
import 'package:aprende_mas/models/activities/activity/activity.dart'; // 👈 Asegúrate que esta ruta es correcta

final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  return ActivityRepositoryImpl();
});

final activityOfflineRepositoryProvider = Provider<ActivityOfflineRepositoryImpl>(
    (ref) => ActivityOfflineRepositoryImpl());

final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
      
  final activityRepository = ref.watch(activityRepositoryProvider);
  final activityOfflineRepository = ref.watch(activityOfflineRepositoryProvider);

  return ActivityNotifier(
    activityOfflineRepository: activityOfflineRepository,
    activityRepository: activityRepository,
    // activityOfflineRepository: activityOfflineRepository
  );
});
final activitiesBySubjectProvider = 
    FutureProvider.family<List<Activity>, int>((ref, subjectId) async {
  
  final activityRepository = ref.watch(activityRepositoryProvider); 

  // 🎯 Llama al nuevo método:
  return activityRepository.getActivitiesBySubject(subjectId);
});

// Provider que contiene el término de búsqueda actual (ej: "Tarea")
final activitySearchTermProvider = StateProvider<String>((ref) => '');

// En lib/providers/activity/activity_provider.dart

final filteredActivitiesProvider = FutureProvider.family<List<Activity>, int>((ref, subjectId) async {
  
  // 1. Obtener el término de búsqueda actual
  final searchTerm = ref.watch(activitySearchTermProvider);
  
  // 2. Obtener los datos brutos (FutureProvider) de la materia
  final activitiesAsyncValue = ref.watch(activitiesBySubjectProvider(subjectId));
  
  // Si los datos aún están cargando o hay error, replicamos ese estado
  if (activitiesAsyncValue.isLoading) {
    // Si la carga está en progreso, retornamos un Future vacío para mantener el tipo
    await Future.value(); 
    return []; 
  }
  if (activitiesAsyncValue.hasError) {
    // Si hay error, propagamos la excepción o retornamos un Future vacío
    throw activitiesAsyncValue.error!;
  }
  
  // 3. Obtener la lista de actividades del AsyncValue
  final activities = activitiesAsyncValue.value ?? [];
  
  // 4. Aplicar el filtro de búsqueda
  if (searchTerm.isEmpty) {
    return activities;
  }
  
  final lowerCaseSearchTerm = searchTerm.toLowerCase();
  
  return activities.where((activity) {
    // 🎯 Aplicar filtro por nombre (o por descripción, si lo deseas)
    return activity.nombreActividad.toLowerCase().contains(lowerCaseSearchTerm);
  }).toList();
});
