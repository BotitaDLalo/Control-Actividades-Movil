import 'dart:convert';

class SubmissionResponse {
  final String texto;
  final List<String> enlaces;
  final List<String> archivos;

  SubmissionResponse({
    required this.texto,
    required this.enlaces,
    required this.archivos,
  });
}

class Submission {
  final int? studentId;
  final int submissionActivityStudentId;
  final int submissionId;
  int? activityId;
  String? answer; // Texto de la respuesta
  String? grade;
  final bool? status;
  final String? submissionDate;
  // Nuevos campos para enlaces y archivos
  List<String>? links;
  List<String>? files;

  Submission({
    this.studentId,
    required this.submissionActivityStudentId,
    required this.submissionId,
    this.submissionDate,
    this.answer,
    this.grade,
    this.activityId,
    this.status,
    this.links,
    this.files,
  });

  // Método para parsear el JSON de respuesta (maneja doble serialización)
  static SubmissionResponse parseRespuestaJson(String? respuestaJson) {
    if (respuestaJson == null || respuestaJson.isEmpty) {
      return SubmissionResponse(texto: '', enlaces: [], archivos: []);
    }
    try {
      final Map<String, dynamic> json = jsonDecode(respuestaJson);
      
      // El campo puede llamarse "Respuesta" o "texto" dependiendo del endpoint
      dynamic respuestaContent = json['Respuesta'] ?? json['texto'] ?? '';
      
      // Verificar si el contenido de respuesta es un JSON stringifyado (doble serialización)
      String textoFinal = '';
      List<String> enlacesFinal = [];
      List<String> archivosFinal = [];
      
      if (respuestaContent is String && respuestaContent.startsWith('{')) {
        try {
          final innerJson = jsonDecode(respuestaContent);
          textoFinal = innerJson['texto'] ?? innerJson['Respuesta'] ?? '';
          enlacesFinal = (innerJson['enlaces'] as List?)?.map((e) => e.toString()).toList() ?? [];
          archivosFinal = (innerJson['archivos'] as List?)?.map((e) => e.toString()).toList() ?? [];
        } catch (e) {
          // Si falla, usar el string directamente
          textoFinal = respuestaContent;
        }
      } else if (respuestaContent is String) {
        textoFinal = respuestaContent;
      } else if (respuestaContent is Map<String, dynamic>) {
        // Ya viene como Map, no como string JSON
        textoFinal = respuestaContent['texto'] ?? respuestaContent['Respuesta'] ?? '';
        enlacesFinal = (respuestaContent['enlaces'] as List?)?.map((e) => e.toString()).toList() ?? [];
        archivosFinal = (respuestaContent['archivos'] as List?)?.map((e) => e.toString()).toList() ?? [];
      }
      
      // Los archivos también pueden venir en el JSON exterior
      if (archivosFinal.isEmpty) {
        archivosFinal = (json['Archivos'] as List?)?.map((e) => e.toString()).toList() ?? 
                        (json['archivos'] as List?)?.map((e) => e.toString()).toList() ?? [];
      }
      
      // Los enlaces también pueden venir en el JSON exterior
      if (enlacesFinal.isEmpty) {
        enlacesFinal = (json['Enlaces'] as List?)?.map((e) => e.toString()).toList() ?? 
                       (json['enlaces'] as List?)?.map((e) => e.toString()).toList() ?? [];
      }
      
      return SubmissionResponse(
        texto: textoFinal,
        enlaces: enlacesFinal,
        archivos: archivosFinal,
      );
    } catch (e) {
      // Si no es JSON válido, retornar como texto plano
      return SubmissionResponse(texto: respuestaJson, enlaces: [], archivos: []);
    }
  }

  static List<Submission> lsSubmissionJsonToLsEntity(
      List<Map<String, dynamic>> lssubmissionRes, int activityId) {
    List<Submission> lsSubmissions = [];

    for (var subRes in lssubmissionRes) {
      final gradeRes = subRes['Calificacion'];
      final submissionStateId = subRes['EstadoEntregaId'];
      
      // Parsear el JSON de respuesta
      final respuestaJson = subRes['Contenido'] as String?;
      final parsedRespuesta = parseRespuestaJson(respuestaJson);

      final sub = Submission(
          submissionActivityStudentId: subRes['EntregaActividadAlumnoId'],
          submissionId: subRes['EntregableId'],
          activityId: subRes['ActividadId'],
          submissionDate: subRes['FechaEntrega'],
          answer: parsedRespuesta.texto, // Usamos el texto parsed
          grade: gradeRes == 0 ? null : gradeRes.toString(),
          status: submissionStateId == 1 ? true : false,
          links: parsedRespuesta.enlaces,
          files: parsedRespuesta.archivos,
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
