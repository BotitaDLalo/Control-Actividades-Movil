import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_datasource_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_datasource.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_repository.dart';
import 'package:aprende_mas/models/models.dart';

class ActivityOfflineRepositoryImpl implements ActivityOfflineRepository {
  final ActivityOfflineDatasource activityOfflineDatasource;

  ActivityOfflineRepositoryImpl(
      {ActivityOfflineDatasource? activityOfflineDatasource})
      : activityOfflineDatasource =
            activityOfflineDatasource ?? ActivityOfflineDatasourceImpl();

  @override
  Future<List<Activity>> getAllActivitiesOffline(int subjectId) {
    return activityOfflineDatasource.getAllActivitiesOffline(subjectId);
  }

  @override
  Future<void> saveSubmissions(List<Submission> lsSubmissions, int activityId) {
    return activityOfflineDatasource.saveSubmissions(lsSubmissions, activityId);
  }

  @override
  Future<List<Submission>> getSubmissionsOffline(int activityId) {
    return activityOfflineDatasource.getSubmissionsOffline(activityId);
  }

  @override
  Future<List<Submission>> sendSubmissionOffline(
      int activityId, String answer) {
    return activityOfflineDatasource.sendSubmissionOffline(activityId, answer);
  }

  @override
  Future<List<Submission>> getSubmissionsPending(int activityId) {
    return activityOfflineDatasource.getSubmissionsPending(activityId);
  }
  
  @override
  Future<void> deleteSubmissionOfflineSent(int submissionId) {
    return activityOfflineDatasource.deleteSubmissionOfflineSent(submissionId);
  }
}
