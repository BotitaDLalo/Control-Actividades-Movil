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
  String? gradedDate;
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
    this.gradedDate,
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
          enlacesFinal = (innerJson['enlaces'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ?? [];
          archivosFinal = (innerJson['archivos'] as List?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  final nombre = e['nombre']?.toString() ?? '';
                  final url = e['url']?.toString() ?? '';
                  return url.isNotEmpty ? url : nombre;
                }
                return e.toString();
              })
              .where((nombre) => nombre.isNotEmpty)
              .toList() ?? [];
        } catch (e) {
          textoFinal = respuestaContent;
        }
      } else if (respuestaContent is String) {
        textoFinal = respuestaContent;
      } else if (respuestaContent is Map<String, dynamic>) {
        textoFinal = respuestaContent['texto'] ?? respuestaContent['Respuesta'] ?? '';
        enlacesFinal = (respuestaContent['enlaces'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ?? [];
        archivosFinal = (respuestaContent['archivos'] as List?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                final nombre = e['nombre']?.toString() ?? '';
                final url = e['url']?.toString() ?? '';
                return url.isNotEmpty ? url : nombre;
              }
              return e.toString();
            })
            .where((nombre) => nombre.isNotEmpty)
            .toList() ?? [];
      }
      
      // Los archivos también pueden venir en el JSON exterior
      if (archivosFinal.isEmpty) {
        archivosFinal = (json['Archivos'] as List?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                return e['nombre']?.toString() ?? e['url']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((nombre) => nombre.isNotEmpty)
            .toList() ?? 
            (json['archivos'] as List?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                return e['nombre']?.toString() ?? e['url']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((nombre) => nombre.isNotEmpty)
            .toList() ?? [];
      }
      
      // Los enlaces también pueden venir en el JSON exterior
      if (enlacesFinal.isEmpty) {
        enlacesFinal = (json['Enlaces'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ?? 
            (json['enlaces'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ?? [];
      }
      
     return SubmissionResponse(
        texto: textoFinal,
        enlaces: enlacesFinal,
        archivos: archivosFinal,
      );
    } catch (e) {
      return SubmissionResponse(texto: respuestaJson, enlaces: [], archivos: []);
    }
  }

  static String? _formatDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      String dateString = dateStr.toString();
      // Handle ASP.NET JSON date format: /Date(1234567890000)/
      if (dateString.startsWith('/Date(')) {
        final match = RegExp(r'\/Date\((\d+)\)\/').firstMatch(dateString);
        if (match != null) {
          final milliseconds = int.parse(match.group(1)!);
          final date = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: false);
          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        }
      }
      // Handle ISO 8601 format
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return null;
    }
  }

  static List<Submission> lsSubmissionJsonToLsEntity(
      List<Map<String, dynamic>> lssubmissionRes, int activityId) {
    List<Submission> lsSubmissions = [];

    for (var subRes in lssubmissionRes) {
      final gradeRes = subRes['Calificacion'];
      final submissionStateId = subRes['EstadoEntregaId'];
      final gradedDateRaw = subRes['FechaCalificado'];
      
      // Parsear el JSON de respuesta
      final respuestaJson = subRes['Contenido'] as String?;
      final parsedRespuesta = parseRespuestaJson(respuestaJson);

      final sub = Submission(
          submissionActivityStudentId: subRes['EntregaActividadAlumnoId'],
          submissionId: subRes['EntregableId'],
          activityId: subRes['ActividadId'],
          submissionDate: subRes['FechaEntrega'],
          answer: parsedRespuesta.texto,
          grade: gradeRes == 0 ? null : gradeRes.toString(),
          gradedDate: _formatDate(gradedDateRaw),
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
