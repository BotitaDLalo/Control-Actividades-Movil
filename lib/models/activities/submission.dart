class Submission {
  final int? studentId;
  final int submissionActivityStudentId;
  final int submissionId;
  int? activityId;
  String? answer;
  String? grade;
  // String? link;
  // String? file;
  final bool? status;
  final String? submissionDate;

  Submission({
    this.studentId,
    required this.submissionActivityStudentId,
    required this.submissionId,
    this.submissionDate,
    this.answer,
    // this.link,
    // this.file,
    this.grade,
    this.activityId,
    this.status
  });

  static List<Submission> lsSubmissionJsonToLsEntity(
      List<Map<String, dynamic>> lssubmissionRes, int activityId) {
    // int gradeRes = submissionRes['Calificacion'] as int;
    // return [
    //   Submission(
    //       studentActivityId: submissionRes['AlumnoActividadId'],
    //       submissionId: submissionRes['EntregaId'],
    //       activityId: activityId,
    //       answer: submissionRes['Respuesta'],
    //       submissionDate: submissionRes['FechaEntrega'],
    //       status: submissionRes['Status'],
    //       grade: gradeRes == 0 ? null : gradeRes.toString())
    // ];

    List<Submission> lsSubmissions = [];

    for (var subRes in lssubmissionRes) {
      final gradeRes = subRes['Calificacion'];

      final submissionStateId = subRes['EstadoEntregaId'];

      final sub = Submission(
          submissionActivityStudentId: subRes['EntregaActividadAlumnoId'],
          submissionId: subRes['EntregableId'],
          activityId: subRes['ActividadId'],
          submissionDate: subRes['FechaEntrega'],
          answer: subRes['Contenido'],
          grade: gradeRes == 0 ? null : gradeRes.toString(),
          status: submissionStateId == 1 ? true: false
          );

      lsSubmissions.add(sub);
    }

    return lsSubmissions;
  }

  static List<Submission> activitiesBySubject(
      List<Submission> lsActivities, int activityId) {
    return lsActivities
        .where(
          (element) => element.activityId == activityId,
        )
        .toList();
  }
}
