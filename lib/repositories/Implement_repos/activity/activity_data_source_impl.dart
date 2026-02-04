import 'package:aprende_mas/models/models.dart';
import 'dart:convert';
import 'dart:io';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/activities/activity/activity_mapper.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activty_datasource.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ActivityDataSourceImpl implements ActivityDataSource {
  final storageService = KeyValueStorageServiceImpl();
  @override
  Future<List<Activity>> getAllActivities(int materiaId) async {
    const uri = "/Actividades/ObtenerActividadesPorMateria";
    debugPrint(
        "🔍 [ACTIVITY] Solicitando actividades: $uri?materiaId=$materiaId");

    // Usar options para asegurar que no se lancen excepciones por status codes
    final response = await dio.get(
      uri,
      queryParameters: {"materiaId": materiaId},
      options: Options(validateStatus: (status) => true),
    );

    debugPrint("📥 [ACTIVITY] Respuesta - Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response.data);
      debugPrint(
          "✅ [ACTIVITY] Actividades parseadas: ${data.length} actividades");
      final activities = ActivityMapper.fromMapList(data);
      return activities;
    } else if (response.statusCode == 400) {
      debugPrint(
          "⚠️ [ACTIVITY] Status 400 para materiaId=$materiaId - Data: ${response.data}");
      // Para errores 400, retornamos lista vacía pero logueamos el error
      return [];
    } else {
      debugPrint(
          "🚨 [ACTIVITY] Status inesperado ${response.statusCode} para materiaId=$materiaId");
      throw Exception(
          "Error obteniendo actividades: Status ${response.statusCode}");
    }
  }

  @override
  Future<Activity> createdActivity(Map<String, dynamic> activityLike) async {
    try {
      const uri = "/Actividades/CrearActividad";
      final response = await dio.post(uri, data: activityLike);
      debugPrint("Response: ${response.data}");

      final activity = ActivityMapper.jsonToEntity(response.data);

      return activity;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(
          "ActivityDataSourceImpl get Error al crear actividades: $e");
      // throw Exception(
      //     "ActivityDataSourceImpl post Error al crear una actividad: $e");
    }
  }

// En activity_data_source_impl.dart

  @override
  Future<Activity> updateActivity(
    int activityId,
    String nombreActividad,
    String descripcion,
    DateTime fechaLimite,
    int puntaje,
    int materiaId,
  ) async {
    try {
      final uri = "/Actividades/ActualizarActividad?id=$activityId";

      // Limpieza de fechas (seguridad extra para SQL Server)
      String fechaLimiteSegura = fechaLimite.toIso8601String().split('.').first;
      String fechaCreacionSegura =
          DateTime.now().toIso8601String().split('.').first;

      final response = await dio.put(uri, data: {
        // --- Identificadores ---
        "ActividadId": activityId,
        "MateriaId": materiaId,
        //"TipoActividadId": 1,
        "Puntaje": puntaje,

        "NombreActividad": nombreActividad,

        // --- Enviamos AMBOS nombres para asegurar compatibilidad ---

        // 1. Nombres probables del modelo C# original
        "Descripcion": descripcion,
        "FechaLimite": fechaLimiteSegura,

        // 2. Nombres según el Log del error anterior
        "DescripcionActividad": descripcion,
        "FechaLimiteActividad": fechaLimiteSegura,

        // Fecha de creación para evitar error de rango SQL
        "FechaCreacionActividad": fechaCreacionSegura,
      });

      debugPrint("Update response: ${response.data}");
      final updatedActivity = ActivityMapper.jsonToEntity(response.data);
      return updatedActivity;
    } catch (e) {
      debugPrint("Error updateActivity: $e");
      if (e is DioException && e.response != null) {
        debugPrint("Detalle del error: ${e.response?.data}");
      }
      throw Exception(
          "ActivityDataSourceImpl error al actualizar actividad: $e");
    }
  }

  @override
  Future<List<Submission>> sendSubmission(int activityId, String answer, {List<String> links = const [], List<String> files = const []}) async {
    try {
      //const uri = "/Alumnos/RegistrarEnvioActividadAlumno";
      const uri = "/Alumnos/RegistrarEnvioActividadAlumnoConEnlaces";
      DateTime dateNow = DateTime.now();
      final id = await storageService.getId();

      // Construir el JSON con la estructura completa (texto, enlaces, archivos)
      final respuestaJson = {
        "texto": answer,
        "enlaces": links,
        "archivos": files,
        "fechaEntrega": dateNow.toIso8601String(),
        "totalArchivos": files.length,
        "totalEnlaces": links.length,
      };

      // Usar FormData para multipart/form-data (requerido por el backend)
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('ActividadId', activityId.toString()),
        MapEntry('AlumnoId', id.toString()),
        MapEntry('Respuesta', jsonEncode(respuestaJson)),
        MapEntry('FechaEntrega', dateNow.toString()),
        MapEntry('TipoEntregaId', '1'),
      ]);

      final res = await dio.post(uri, data: formData);

      if (res.statusCode == 200) {
        final resList = List<Map<String, dynamic>>.from(res.data['Datos'] ?? []);

        final list = Submission.lsSubmissionJsonToLsEntity(resList, activityId);

        return list;
      }

      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // Método para subir un archivo y obtener la URL
  @override
  Future<String> uploadFile(PlatformFile file, int activityId, int studentId) async {
    try {
      const uri = "/Archivos/SubirArchivo";
      
      // Crear FormData con el archivo
      final formData = FormData();
      
      // Agregar IDs requeridos por el backend
      formData.fields.addAll([
        MapEntry('ActividadId', activityId.toString()),
        MapEntry('AlumnoId', studentId.toString()),
      ]);
      
      // Leer el archivo como bytes
      final fileBytes = await File(file.path!).readAsBytes();
      
      // Agregar el archivo al FormData
      formData.files.add(MapEntry(
        'archivo',
        MultipartFile.fromBytes(
          fileBytes,
          filename: file.name,
        ),
      ));
      
      final res = await dio.post(uri, data: formData);
      
      if (res.statusCode == 200) {
        final url = res.data['url'] as String? ?? res.data['fileUrl'] as String?;
        if (url != null) {
          debugPrint("✅ Archivo subido exitosamente: $url");
          return url;
        } else {
          throw Exception("El servidor no devolvió una URL");
        }
      } else {
        throw Exception("Error al subir archivo: Status ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error subiendo archivo: $e");
      throw Exception("Error al subir archivo: $e");
    }
  }

  @override
  Future<List<Submission>> getSubmissions(int activityId) async {
    const uri = "/Alumnos/ObtenerEnviosActividadesAlumno";
    final id = await storageService.getId();

    final res = await dio.get(
      uri,
      queryParameters: {"ActividadId": activityId, "AlumnoId": id},
      options: Options(validateStatus: (status) => true),
    );

    if (res.statusCode == 200) {
      // final resList = Map<String, dynamic>.from(res.data);
      final resList = List<Map<String, dynamic>>.from(res.data);
      final list = Submission.lsSubmissionJsonToLsEntity(resList, activityId);
      return list;
    } else if (res.statusCode == 400) {
      debugPrint(
          "⚠️ [SUBMISSION] Status 400 para activityId=$activityId - Data: ${res.data}");
      return [];
    } else {
      debugPrint(
          "🚨 [SUBMISSION] Status inesperado ${res.statusCode} para activityId=$activityId");
      return [];
    }
  }

  @override
  Future<List<Submission>> cancelSubmission(
      int studentActivityId, int activityId) async {
    try {
      const uri = "/Alumnos/CancelarEnvioActividadAlumno";
      final id = await storageService.getId();

      final res = await dio.post(uri, data: {
        "AlumnoActividadId": studentActivityId,
        "ActividadId": activityId,
        "AlumnoId": id
      });

      if (res.statusCode == 200) {
        // final resList = Map<String, dynamic>.from(res.data);
        final resList = List<Map<String, dynamic>>.from(res.data);

        final list = Submission.lsSubmissionJsonToLsEntity(resList, activityId);

        return list;
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<ActivityStudentSubmissionsData> getStudentSubmissions(
      int activityId) async {
    try {
      const uri = "/Actividades/ObtenerAlumnosEntregables";

      final res =
          await dio.get(uri, queryParameters: {"actividadId": activityId});
      if (res.statusCode == 200) {
        final response = Map<String, dynamic>.from(res.data);
        final entity =
            ActivityStudentSubmissionsData.responseToEntity(response);
        return entity;
      }
      return ActivityStudentSubmissionsData.init();
    } catch (e) {
      print(e);
      return ActivityStudentSubmissionsData.init();
    }
  }

  @override
  Future<bool> submissionGrading(int submissionId, int grade) async {
    try {
      const uri = "/Actividades/AsignarCalificacion";

      final res = await dio.post(uri,
          data: {"EntregableId": submissionId, "Calificacion": grade});

      if (res.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    try {
      const uri = "/Actividades/EliminarActividad?id=";
      await dio.delete(uri + activityId.toString());
    } catch (e) {
      throw UncontrolledError();
    }
  }
}
