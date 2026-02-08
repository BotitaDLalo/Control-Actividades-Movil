import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activity_state.dart';
import 'package:aprende_mas/providers/activity/activity_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_repository_impl.dart';
import 'package:aprende_mas/models/activities/activity/activity.dart'; // 👈 Asegúrate que esta ruta es correcta

final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  return ActivityRepositoryImpl();
});

final activityOfflineRepositoryProvider =
    Provider<ActivityOfflineRepositoryImpl>(
        (ref) => ActivityOfflineRepositoryImpl());

final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final activityOfflineRepository =
      ref.watch(activityOfflineRepositoryProvider);

  return ActivityNotifier(
    activityOfflineRepository: activityOfflineRepository,
    activityRepository: activityRepository,
    // activityOfflineRepository: activityOfflineRepository
  );
});
final activitiesBySubjectProvider =
    FutureProvider.family<List<Activity>, int>((ref, subjectId) async {
  // Se obtienen ambos repositorios
  final activityRepository = ref.watch(activityRepositoryProvider);
  final activityOfflineRepository = ref.watch(activityOfflineRepositoryProvider);

  try {
    // Se intenta obtener los datos de la fuente online primero
    final onlineActivities =
        await activityRepository.getActivitiesBySubject(subjectId);
    return onlineActivities;
  } catch (e) {
    // Si la carga online falla, se recurre a la fuente de datos offline
    print(
        "Fallo al cargar actividades online, usando caché offline. Error: $e");
    return activityOfflineRepository.getAllActivitiesOffline(subjectId);
  }
});

// Provider que contiene el término de búsqueda actual (ej: "Tarea")
final activitySearchTermProvider = StateProvider<String>((ref) => '');

// En lib/providers/activity/activity_provider.dart

final filteredActivitiesProvider =
    Provider.family<AsyncValue<List<Activity>>, int>((ref, subjectId) {
  final searchTerm = ref.watch(activitySearchTermProvider).toLowerCase();

  final activitiesAsync =
      ref.watch(activitiesBySubjectProvider(subjectId));

  return activitiesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (activities) {
      if (searchTerm.isEmpty) {
        return AsyncValue.data(activities);
      }

      final filtered = activities.where((activity) {
        return activity.nombreActividad
            .toLowerCase()
            .contains(searchTerm);
      }).toList();

      return AsyncValue.data(filtered);
    },
  );
});
