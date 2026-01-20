import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups/groups_data_source.dart';
import 'package:aprende_mas/config/utils/utils.dart';

class GroupsDataSourceImpl implements GroupsDataSource {
  final storageService = KeyValueStorageServiceImpl();
  final cn = CatalogNames();
  @override
  Future<List<Group>> getGroupsSubjects() async {
    try {
      final id = await storageService.getId();
      final role = await storageService.getRole();
      List<Map<String, dynamic>> resList = [];

      if (role == cn.getRoleTeacherName) {
        const uri = "/Grupos/ObtenerGruposMateriasDocente";
        debugPrint("🔍 [LOGIN] Solicitando grupos del docente: $uri?docenteId=$id");
        final res = await dio.get(
          uri,
          queryParameters: {'docenteId': id},
          options: Options(validateStatus: (status) => true),
        );
        debugPrint("📥 [LOGIN] Respuesta docente - Status: ${res.statusCode}");
        if (res.statusCode == 200) {
          resList = List<Map<String, dynamic>>.from(res.data);
        } else if (res.statusCode == 400) {
          debugPrint("⚠️ [LOGIN] Status 400 para docente - Data: ${res.data}");
          resList = [];
        } else {
          debugPrint("🚨 [LOGIN] Status inesperado ${res.statusCode} para docente");
          resList = [];
        }
      } else if (role == cn.getRoleStudentName) {
        const uri = "/Grupos/ObtenerGruposMateriasAlumno";
        debugPrint("🔍 [LOGIN] Solicitando grupos del alumno: $uri?alumnoId=$id");
        final res = await dio.get(
          uri,
          queryParameters: {'alumnoId': id},
          options: Options(validateStatus: (status) => true),
        );
        debugPrint("📥 [LOGIN] Respuesta alumno - Status: ${res.statusCode}");
        if (res.statusCode == 200) {
          resList = List<Map<String, dynamic>>.from(res.data);
        } else if (res.statusCode == 400) {
          debugPrint("⚠️ [LOGIN] Status 400 para alumno - Data: ${res.data}");
          resList = [];
        } else {
          debugPrint("🚨 [LOGIN] Status inesperado ${res.statusCode} para alumno");
          resList = [];
        }
      }
      final groups = Group.groupsJsonToEntityList(resList);
      debugPrint("✅ [LOGIN] Grupos parseados exitosamente: ${groups.length} grupos");
      return groups;
    } on DioException catch (e) {
      debugPrint("🚨 [LOGIN] DioException en getGroupsSubjects: ${e.message}");
      debugPrint("🚨 [LOGIN] Status Code: ${e.response?.statusCode}");
      debugPrint("🚨 [LOGIN] Response Data: ${e.response?.data}");
      debugPrint("🚨 [LOGIN] Request: ${e.requestOptions.method} ${e.requestOptions.path}");
      // Re-throw DioException para que sea capturado por catchError en auth_state_notifier
      rethrow;
    } catch (e) {
      debugPrint("🚨 [LOGIN] Error inesperado en getGroupsSubjects: $e");
      throw Exception(e);
    }
  }

  @override
  Future<List<GroupsCreated>> getCreatedGroups() async {
    try {
      const uri = "/Grupos/ObtenerGruposCreados";
      final id = await storageService.getId();
      final res = await dio.get(uri, queryParameters: {'docenteid': id});
      final resList = List<Map<String, dynamic>>.from(res.data);
      final lsGroups = GroupsCreated.groupsCreatedToEntityList(resList);
      return lsGroups;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Group>> createGroupSubjects(String groupName, String description,
        List<SubjectsRow> subjectsList) async {
    try {
      const uri = "/Grupos/CrearGrupoMaterias";
      final id = await storageService.getId();
      final subList = subjectsList
          .map((subject) => subject.toJsonGroupsSubjects())
          .toList();

      debugPrint("📤 Enviando POST a: $uri");
      debugPrint("📤 Datos: DocenteId=$id, NombreGrupo=$groupName");
      final res = await dio.post(uri, data: {
        "DocenteId": id,
        "NombreGrupo": groupName,
        "Descripcion": description,
        "Materias": subList
      });
      debugPrint("📥 Status Code: ${res.statusCode}");
      debugPrint("📥 Response Data: ${res.data}");

      if (res.statusCode == 200) {
        if (res.data != null && res.data is List) {
          try {
            // Conversión más segura que maneja nulls en campos internos
            final cleanData = res.data.where((item) => item != null).map((item) {
              if (item is Map<String, dynamic>) {
                // Asegurar que campos de lista no sean null
                return item.map((key, value) {
                  if (value == null && (key == 'Materias' || key == 'materias')) {
                    return MapEntry(key, <dynamic>[]);
                  }
                  return MapEntry(key, value);
                });
              }
              return item;
            }).toList();

            final resLista = List<Map<String, dynamic>>.from(cleanData);
            final groups = Group.groupsJsonToEntityList(resLista);
            debugPrint("✅ Grupos creados: ${groups.length}");
            return groups;
          } catch (e) {
            debugPrint("❌ Error convirtiendo response data: $e");
            debugPrint("❌ Response data type: ${res.data.runtimeType}");
            // Mostrar más detalles del error
            for (var i = 0; i < res.data.length; i++) {
              debugPrint("❌ Item $i: ${res.data[i]} (type: ${res.data[i]?.runtimeType})");
            }
            return [];
          }
        } else {
          debugPrint("❌ Response data es null o no es List: ${res.data?.runtimeType}");
          return [];
        }
      }
      debugPrint("❌ Status code no es 200: ${res.statusCode}");
      return [];
    } catch (e) {
      debugPrint("❌ Error en createGroupSubjects: $e");
      return [];
    }
  }

  //$CREAR GRUPO SIN MATERIAS
  @override
  Future<List<Group>> createGroup(
      String nombreGrupo, String descripcion) async {
    const uri = "/Grupos/CrearGrupo";
    final id = await storageService.getId();
    try {
      final res = await dio.post(uri, data: {
        "NombreGrupo": nombreGrupo,
        "Descripcion": descripcion,
        "DocenteId": id
      });
      if (res.statusCode == 200) {
        final groups = Group.groupsJsonToEntityList(res.data);
        return groups;
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> deleteGroup(int groupId) async {
    try {
      const uri = "/Grupos/DeleteGroup";
      final fullUri = "$uri/$groupId";
      debugPrint("🔍 DELETE URL: $fullUri (groupId: $groupId)");
      final response = await dio.delete(fullUri);
      debugPrint("🔍 Response status: ${response.statusCode}");
      debugPrint("🔍 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Grupo eliminado exitosamente'};
      } else if (response.statusCode == 409) {
        String message = 'No se puede eliminar el grupo';
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['Mensaje'] != null) message = data['Mensaje'];
          if (data['Detalles'] != null) message += '\n${data['Detalles']}';
        }
        return {'success': false, 'message': message};
      } else if (response.statusCode == 500) {
        return {'success': false, 'message': 'Error interno del servidor. Por favor, contacte al soporte técnico.'};
      } else {
        return {'success': false, 'message': 'Error desconocido al eliminar el grupo'};
      }
    } catch (e) {
      debugPrint("❌ Error en deleteGroup: $e");
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  @override
  Future<Group> updateGroup(int groupId, String groupName,
      String descriptionGroup) async {
    try {
      const uri = "/Grupos/ActualizarGrupo";
      final id = await storageService.getId();
      final res = await dio.put(uri, data: {
        "GrupoId": groupId,
        "NombreGrupo": groupName,
        "Descripcion": descriptionGroup,
        "DocenteId": id
      });

      if (res.statusCode == 200) {
        final group = Group.groupToEntity(res.data);
        return group;
      }
      return Group.empty();
    } catch (e) {
      print(e);
      return Group.empty();
    }
  }

  @override
  Future<VerifyEmail> verifyEmail(String email) async {
    try {
      const uri = "/Alumnos/VerificarAlumnoEmail";
      final res = await dio.post(uri, data: {"Email": email});

      if (res.statusCode == 200) {
        final verifyEmail = VerifyEmail.verifyEmailToEntity(res.data, true);
        return verifyEmail;
      }
      return VerifyEmail.verifyEmailToEntity({}, false);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<StudentGroupSubject>> addStudentsGroup(
      int groupId, List<String> emails) async {
    try {
      const uri = "/Alumnos/RegistrarAlumnoGMDocente";

      final res =
          await dio.post(uri, data: {"Emails": emails, "GrupoId": groupId});

      if (res.statusCode == 200) {
        final resList = List<Map<String, dynamic>>.from(res.data);
        final lsStudents =
            StudentGroupSubject.studentGroupSubjectJsonToEntity(resList);
        return lsStudents;
      }
      return [];
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<StudentGroupSubject>> getStudentsGroup(int subjectId) async {
    try {
      const uri = "/Alumnos/ObtenerListaAlumnosGrupo";
      final res = await dio.post(uri, data: {"GrupoId": subjectId});

      if (res.statusCode == 200) {
        final resList = List<Map<String, dynamic>>.from(res.data);
        final lsStudents =
            StudentGroupSubject.studentGroupSubjectJsonToEntity(resList);
        return lsStudents;
      }
      return [];
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Map<String, dynamic>> removeStudentFromGroup({
    required int groupId,
    required int studentId
  }) async {
    try {
      // Ruta corregida para ser consistente con otros endpoints
      const uri = "/Alumnos/EliminarAlumnoGrupo";

      final res = await dio.post(
        uri,
        data: {
          "GrupoId": groupId,
          "AlumnoId": studentId,
        }
      );

      if (res.statusCode == 200) {
        return {'success': true, 'message': 'Alumno eliminado del grupo exitosamente'};
      } else if (res.statusCode == 409) {
        String message = 'No se puede eliminar al alumno del grupo';
        if (res.data is Map<String, dynamic>) {
          final data = res.data as Map<String, dynamic>;
          if (data['Mensaje'] != null) message = data['Mensaje'];
          if (data['Detalles'] != null) message += '\n${data['Detalles']}';
        }
        return {'success': false, 'message': message};
      } else if (res.statusCode == 500) {
        return {'success': false, 'message': 'Error interno del servidor. Por favor, contacte al soporte técnico.'};
      } else {
        return {'success': false, 'message': 'Error desconocido al eliminar al alumno del grupo'};
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 400) {
        final errorData = e.response?.data;
        final serverMessage = errorData?['mensaje'] ?? 'Error desconocido del servidor.';
        return {'success': false, 'message': serverMessage};
      }
      debugPrint('Error general de la API: $statusCode');
      return {'success': false, 'message': 'Error en la conexión o servidor.'};
    } catch (e) {
      debugPrint('Error en GroupsDataSourceImpl: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
