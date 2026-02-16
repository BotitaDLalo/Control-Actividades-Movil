import 'package:aprende_mas/models/activities/activity/activity.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_offline_datasource.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activity_repository.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activty_datasource.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:file_picker/file_picker.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityDataSource activityDataSource;

  ActivityRepositoryImpl({ActivityDataSource? activityDataSource})
      : activityDataSource = activityDataSource ?? ActivityDataSourceImpl();

  @override
  Future<List<Activity>> getAllActivities(int materiaId) async {
    final activities = await activityDataSource.getAllActivities(materiaId);
    return activities;
  }

  @override
  Future<Activity> updateActivity(
      int activityId, 
      String nombreActividad,
      String descripcion, 
      DateTime fechaLimite, 
      int puntaje,
      int materiaId,
      {bool permitirEntregasTarde = false, bool tieneLimiteEntregas = false, int limiteEntregasPorAlumno = 0}
  ) {
    return activityDataSource.updateActivity(
        activityId, 
        nombreActividad, 
        descripcion, 
        fechaLimite, 
        puntaje,
        materiaId,
        permitirEntregasTarde: permitirEntregasTarde,
        tieneLimiteEntregas: tieneLimiteEntregas,
        limiteEntregasPorAlumno: limiteEntregasPorAlumno
    );
  }

  @override
  Future<Activity> createdActivity(Map<String, dynamic> activityLike) {
    return activityDataSource.createdActivity(activityLike);
  }

  @override
  Future<bool> sendSubmission(int activityId, String answer, {List<String> links = const [], List<String> files = const []}) {
    return activityDataSource.sendSubmission(activityId, answer, links: links, files: files);
  }

  @override
  Future<String> uploadFile(PlatformFile file, int activityId, int studentId) async {
    return await activityDataSource.uploadFile(file, activityId, studentId);
  }

  @override
  Future<List<Submission>> getSubmissions(int activityId) {
    return activityDataSource.getSubmissions(activityId);
  }

  @override
  Future<bool> cancelSubmission(
      int studentActivityId, int activityId) {
    return activityDataSource.cancelSubmission(studentActivityId, activityId);
  }

  @override
  Future<ActivityStudentSubmissionsData> getStudentSubmissions(int activityId) {
    return activityDataSource.getStudentSubmissions(activityId);
  }

  @override
  Future<bool> submissionGrading(int submissionId, double grade) {
    return activityDataSource.submissionGrading(submissionId, grade);
  }

  @override
  Future<bool> removeGrade(int submissionId) {
    return activityDataSource.removeGrade(submissionId);
  }

  @override
  Future<void> deleteActivity(int activityId) {
    return activityDataSource.deleteActivity(activityId);
  }
  
  @override
  Future<List<Activity>> getActivitiesBySubject(int materiaId) async {
    final activities = await activityDataSource.getAllActivities(materiaId);
    return activities;
  }

}
