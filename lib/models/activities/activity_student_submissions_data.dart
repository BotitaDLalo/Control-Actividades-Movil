import 'dart:convert';
import 'student_submission.dart';
import 'submission.dart';

class ActivityStudentSubmissionsData {
  final int activityId;
  final double score;
  final int totalSubmissions;
  List<StudentSubmission> lsStudentsSubmissions;
  ActivityStudentSubmissionsData(
      {required this.activityId,
      required this.score,
      required this.totalSubmissions,
      required this.lsStudentsSubmissions});

  static ActivityStudentSubmissionsData init() {
    return ActivityStudentSubmissionsData(
        activityId: -1,
        score: 0,
        totalSubmissions: 0,
        lsStudentsSubmissions: []);
  }

  static ActivityStudentSubmissionsData responseToEntity(
      Map<String, dynamic> response) {
    final lsResponse = response['AlumnosEntregables'] as List<dynamic>;
    return ActivityStudentSubmissionsData(
        activityId: response['ActividadId'] as int,
        score: (response['Puntaje'] as num).toDouble(),
        totalSubmissions: response['TotalEntregados'] as int,
        lsStudentsSubmissions: lsResponse
            .map(
              (e) {
                final respuestaJson = e['Respuesta'] as String?;
                final parsedRespuesta = Submission.parseRespuestaJson(respuestaJson);
                
                return StudentSubmission(
                    submissionId: e['EntregaId'] as int,
                    studentId: e['AlumnoId'] as int,
                    userName: e['NombreUsuario'] as String,
                    names: e['Nombres'] as String,
                    lastName: e['ApellidoPaterno'] as String,
                    lastName2: e['ApellidoMaterno'] as String,
                    submissionDate: e['FechaEntrega'].toString(),
                    answer: parsedRespuesta.texto,
                    links: parsedRespuesta.enlaces,
                    files: parsedRespuesta.archivos.map((nombre) {
                      return FileSubmission(nombre: nombre, ruta: '');
                    }).toList(),
                    grade: (e['Calificacion'] as num).toDouble());
              },
            )
            .toList());
  }
}
