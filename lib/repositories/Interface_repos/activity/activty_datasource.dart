import 'package:aprende_mas/models/models.dart';
import 'package:file_picker/file_picker.dart';

abstract class ActivityDataSource {
  Future<List<Activity>> getAllActivities(int materiaId);

  Future<Activity> createdActivity(Map<String, dynamic> activityLike);

  Future<void> deleteActivity(int activityId);

  Future<Activity> updateActivity(int activityId, String nombreActividad,
      String descripcion, DateTime fechaLimite, int puntaje, int materiaId,
      {bool permitirEntregasTarde = false, bool tieneLimiteEntregas = false, int limiteEntregasPorAlumno = 0});

  Future<bool> sendSubmission(int activityId, String answer, {List<String> links = const [], List<String> files = const []});

  Future<String> uploadFile(PlatformFile file, int activityId, int studentId);

  Future<List<Submission>> getSubmissions(int activityId);

  Future<bool> cancelSubmission(
      int studentActivityId, int activityId);

  Future<ActivityStudentSubmissionsData> getStudentSubmissions(int activityId);

  Future<bool> submissionGrading(int submissionId, double grade);

  Future<bool> removeGrade(int submissionId);
}
