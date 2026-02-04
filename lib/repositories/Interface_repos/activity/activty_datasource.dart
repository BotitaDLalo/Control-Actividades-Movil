import 'package:aprende_mas/models/models.dart';
import 'package:file_picker/file_picker.dart';

abstract class ActivityDataSource {
  Future<List<Activity>> getAllActivities(int materiaId);

  Future<Activity> createdActivity(Map<String, dynamic> activityLike);

  Future<void> deleteActivity(int activityId);

  Future<Activity> updateActivity(int activityId, String nombreActividad,
      String descripcion, DateTime fechaLimite, int puntaje, int materiaId);

  Future<List<Submission>> sendSubmission(int activityId, String answer, {List<String> links = const [], List<String> files = const []});

  Future<String> uploadFile(PlatformFile file, int activityId, int studentId);

  Future<List<Submission>> getSubmissions(int activityId);

  Future<List<Submission>> cancelSubmission(
      int studentActivityId, int activityId);

  Future<ActivityStudentSubmissionsData> getStudentSubmissions(int activityId);

  Future<bool> submissionGrading(int submissionId, int grade);
}
