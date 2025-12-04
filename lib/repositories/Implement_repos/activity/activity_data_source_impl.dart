import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/activities/activity/activity_mapper.dart';
import 'package:aprende_mas/repositories/Interface_repos/activity/activty_datasource.dart';
import 'package:aprende_mas/config/data/data.dart';

class ActivityDataSourceImpl implements ActivityDataSource {
  final storageService = KeyValueStorageServiceImpl();
  @override
  Future<List<Activity>> getAllActivities(int materiaId) async {
    try {
      const uri = "/Actividades/ObtenerActividadesPorMateria";
      final response = await dio.get(uri, queryParameters: {"materiaId":materiaId});

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response.data);

      debugPrint("Respuesta del backend: ${response.data}");

      final activities = ActivityMapper.fromMapList(data);
      return activities;
    } catch (e) {
      throw Exception(
          "ActivityDataSourceImpl get Error al obtener actividades: $e");
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
      throw Exception("ActivityDataSourceImpl get Error al crear actividades: $e");
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
      String fechaCreacionSegura = DateTime.now().toIso8601String().split('.').first;

      final response = await dio.put(
        uri,
        data: {
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
        }
      );

      debugPrint("Update response: ${response.data}");
      final updatedActivity = ActivityMapper.jsonToEntity(response.data);
      return updatedActivity;

    } catch (e) {
      debugPrint("Error updateActivity: $e");
      if(e is DioException && e.response != null) {
          debugPrint("Detalle del error: ${e.response?.data}");
      }
      throw Exception("ActivityDataSourceImpl error al actualizar actividad: $e");
    }
  }

  @override
  Future<List<Submission>> sendSubmission(int activityId, String answer) async {
    try {
      const uri = "/Alumnos/RegistrarEnvioActividadAlumno";
      DateTime dateNow = DateTime.now();
      final id = await storageService.getId();

      final res = await dio.post(uri, data: {
        "ActividadId": activityId,
        "AlumnoId": id,
        "Respuesta": answer,
        "FechaEntrega": dateNow.toString()
      });

      if (res.statusCode == 200) {
        final resList = Map<String, dynamic>.from(res.data);

        final list = Submission.submissionJsonToEntity(resList, activityId);

        return list;
      }

      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<List<Submission>> getSubmissions(int activityId) async {
    try {
      const uri = "/Alumnos/ObtenerEnviosActividadesAlumno";
      final id = await storageService.getId();

      final res = await dio.get(uri,
          queryParameters: {"ActividadId": activityId, "AlumnoId": id});
      if (res.statusCode == 200) {
        final resList = Map<String, dynamic>.from(res.data);

        final list = Submission.submissionJsonToEntity(resList, activityId);

        return list;
      }

      return [];
    } catch (e) {
      debugPrint(e.toString());
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
        final resList = Map<String, dynamic>.from(res.data);

        final list = Submission.submissionJsonToEntity(resList, activityId);

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

      final res = await dio
          .post(uri, data: {"EntregaId": submissionId, "Calificacion": grade});

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
