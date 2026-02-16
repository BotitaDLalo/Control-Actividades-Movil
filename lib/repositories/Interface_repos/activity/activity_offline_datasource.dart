import 'package:aprende_mas/models/models.dart';

abstract class ActivityOfflineDatasource {
  Future<List<Activity>> getAllActivitiesOffline(int subjectId);
  Future<void> saveActivitiesOffline(List<Activity> lsActivities, int subjectId);
  Future<void> saveSubmissions(List<Submission> lsSubmissions, int activityId);
  Future<List<Submission>> getSubmissionsOffline(int activityId);
  Future<List<Submission>> sendSubmissionOffline(int activityId, String answer);
  Future<List<Submission>> getSubmissionsPending(int activityId);
  Future<void> deleteSubmissionOfflineSent(int submissionId);
  Future<List<Submission>> getAllPendingSubmissions();
}
