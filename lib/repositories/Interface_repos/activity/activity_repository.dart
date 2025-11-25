import 'package:aprende_mas/models/models.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getAllActivities(int materiaId);

  Future<Activity> createdActivity(Map<String, dynamic> activityLike);

  Future<void> deleteActivity(int activityId);

  Future<Activity> updateActivity(int activityId, String nombreActividad,
      String descripcion, DateTime fechaLimite, int puntaje, int materiaId);

  Future<List<Submission>> sendSubmission(int activityId, String answer);

  Future<List<Submission>> getSubmissions(int activityId);

  Future<List<Submission>> cancelSubmission(
      int studentActivityId, int activityId);

  Future<ActivityStudentSubmissionsData> getStudentSubmissions(int activityId);

  Future<bool> submissionGrading(int submissionId, int grade);
}
