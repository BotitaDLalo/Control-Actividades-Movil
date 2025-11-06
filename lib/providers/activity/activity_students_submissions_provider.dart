import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_repository_impl.dart';

final activityStudentsSubmissionsProvider =
    FutureProvider.autoDispose.family<ActivityStudentSubmissionsData, int>(
  (ref, activityId) async {
    final activityRepository = ActivityRepositoryImpl();

    final lsStudentsSubmissions =
        await activityRepository.getStudentSubmissions(activityId);

    return lsStudentsSubmissions;
  },
);