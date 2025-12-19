import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/subjects/subjects_data_source.dart';

class SubjectsDataSourceImpl implements SubjectsDataSource {
  final storageService = KeyValueStorageServiceImpl();
  final cn = CatalogNames();
  @override
  Future<List<Subject>> getSubjectsWithoutGroup() async {
    try {
      final id = await storageService.getId();
      final role = await storageService.getRole();
      List<Map<String, dynamic>> resList = [];

      if (role == cn.getRoleTeacherName) {
        const uri = "/Materias/ObtenerMateriasDocente";
        debugPrint("🔍 [LOGIN] Solicitando materias del docente: $uri?docenteId=$id");
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
        const uri = "/Materias/ObtenerMateriasAlumno";
        debugPrint("🔍 [LOGIN] Solicitando materias del alumno: $uri?alumnoId=$id");
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

      final lsSubjects = Subject.subjectsJsonToEntityList(resList);
      debugPrint("✅ [LOGIN] Materias parseadas exitosamente: ${lsSubjects.length} materias");
      return lsSubjects;
    } on DioException catch (e) {
      debugPrint("🚨 [LOGIN] DioException en getSubjectsWithoutGroup: ${e.message}");
      debugPrint("🚨 [LOGIN] Status Code: ${e.response?.statusCode}");
      debugPrint("🚨 [LOGIN] Response Data: ${e.response?.data}");
      debugPrint("🚨 [LOGIN] Request: ${e.requestOptions.method} ${e.requestOptions.path}");
      // Re-throw DioException para que sea capturado por catchError en auth_state_notifier
      rethrow;
    } catch (e) {
      debugPrint("🚨 [LOGIN] Error inesperado en getSubjectsWithoutGroup: $e");
      throw Exception(e);
    }
  }

  @override
  Future<List<Group>> createSubjectWithGroup(String subjectName,
      String description, Color colorCode, List<int> groupsId) async {
    try {
      const uri = "/Materias/CrearMateriaGrupos";
      final id = await storageService.getId();
      debugPrint("📝 Creando materia '$subjectName' para grupos: $groupsId");
      final res = await dio.post(uri, data: {
        "NombreMateria": subjectName,
        "Descripcion": description,
        // "CodigoColor": colorCode.toString(),
        "DocenteId": id,
        "Grupos": groupsId
      });
      debugPrint("📥 Status Code: ${res.statusCode}");
      debugPrint("📥 Response Data: ${res.data}");

      if (res.statusCode == 200) {
        debugPrint("✅ Materia creada exitosamente en backend");
        // El backend ahora retorna un mensaje, no la lista de grupos
        // La actualización se hace con getGroupsSubjects después
        return [];
      } else {
        debugPrint("❌ Status code ${res.statusCode}: ${res.data}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Error creando materia con grupos: $e");
      throw Exception(e);
    }
  }

  @override
  Future<List<Subject>> createSubjectWithoutGroup(
      String subjectName, String description, Color colorCode) async {
    try {
      const uri = "/Materias/CrearMateriaSinGrupo";

      final id = await storageService.getId();
      final res = await dio.post(uri, data: {
        "NombreMateria": subjectName,
        "Descripcion": description,
        // "CodigoColor": colorCode,
        "DocenteId": id
      });
      final resList = List<Map<String, dynamic>>.from(res.data);
      final lsSubjects = Subject.subjectsJsonToEntityList(resList);
      return lsSubjects;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> deleteSubject(int subjectId) async {
    try {
      const uri = "/Materias/DeleteSubject";
      final fullUri = "$uri/$subjectId";
      debugPrint("🔍 Intentando eliminar materia con ID: $subjectId");
      debugPrint("🔍 URL: $fullUri");
      final response = await dio.delete(fullUri);
      debugPrint("🔍 Status Code: ${response.statusCode}");
      debugPrint("🔍 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        debugPrint("✅ Materia eliminada exitosamente");
        return true;
      } else {
        debugPrint("❌ Error del servidor: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error de conexión al eliminar materia: $e");
      return false;
    }
  }

  @override
  Future<Subject> updateSubject(int subjectId, String name, String description) async {
    try {
      const uri = "/Materias/UpdateSubject";
      final res = await dio.put(uri, data: {
        "MateriaId": subjectId,
        "NombreMateria": name,
        "Descripcion": description,
      });

      if (res.statusCode == 200) {
        // Assuming the response contains the updated subject
        final subjectMap = res.data as Map<String, dynamic>;
        final updatedSubject = Subject(
          materiaId: subjectMap['MateriaId'],
          nombreMateria: subjectMap['NombreMateria'],
          descripcion: subjectMap['Descripcion'] ?? "",
          codigoAcceso: subjectMap['CodigoAcceso'] ?? "",
          codigoColor: subjectMap['CodigoColor'] ?? "",
        );
        return updatedSubject;
      } else {
        throw Exception("Error updating subject: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // --- CÓDIGO CORREGIDO EN subjects_data_source_impl.dart ---

// --- CÓDIGO CORREGIDO EN subjects_data_source_impl.dart ---

@override
Future<List<StudentGroupSubject>> addStudentsSubject(
    int subjectId, List<String> emails) async {
  
  // Manejo del ID... (se asume que ya lo tienes fuera del try)
final docenteId = await storageService.getId();

// 2. Manejo de null: Si es null, lanzamos una excepción limpia.
if (docenteId == null) {
    throw Exception("Docente ID not found in storage."); 
}
// Si llega aquí, docenteId es un int no nulo.

const uri = "/Alumnos/RegistrarAlumnoGMDocente";

try {
  final res = await dio.post(
    uri, 
    data: {
      "Emails": emails, 
      "MateriaId": subjectId,
      "DocenteId": docenteId // Usamos la variable verificada
    }
    
  );

    // Si la solicitud es exitosa (código 200), devuelve la lista
    final resList = List<Map<String, dynamic>>.from(res.data);
    return StudentGroupSubject.studentGroupSubjectJsonToEntity(resList); 

  } on DioException catch (e) {
    // Si la API devuelve un error 4xx o 5xx
    final statusCode = e.response?.statusCode;
    
    // 1. Manejo del 400 (Error de Negocio)
    if (statusCode == 400) {
      // 🚨 Lanzamos una excepción con el mensaje del servidor
      final errorData = e.response?.data;
      final serverMessage = errorData?['mensaje'] ?? 'Error desconocido del servidor.';
      throw Exception(serverMessage);
    }
    
    // 2. Manejo de otros errores (404, 500, etc.)
    debugPrint('Error general de la API al asignar alumnos: $statusCode');
    throw Exception('Error en la conexión o servidor.');
    
  } catch (e) {
    // Errores de parsing o fallos de red
    throw Exception(e); 
  }
}



  @override
  Future<List<StudentGroupSubject>> getStudentsSubject(int? groupId,int subjectId) async {
    try {
      const uri = "/Alumnos/ObtenerListaAlumnosMateria";
      final res = await dio.post(uri, data: {"GrupoId": groupId ?? 0
      , "MateriaId": subjectId});

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
  Future<bool> removeStudent({
    required int subjectId, 
    required int studentId
  }) async {
    try {
      // 💡 URI HIPOÉTÉTICA para eliminar un alumno de una materia
      // Puedes ajustarla según tu API. Usaremos un POST similar a tus otros métodos,
      // pero idealmente deberías usar DELETE.
      const uri = "/Alumnos/EliminarAlumnoMateria"; // O /Materias/{subjectId}/Alumnos/{studentId}

      final res = await dio.post(
        uri, 
        data: {
          "MateriaId": subjectId,
          "AlumnoId": studentId,
          // Si necesitas el ID del docente, puedes obtenerlo aquí también:
          // "DocenteId": await storageService.getId(), 
        }
      );

      // Evaluar la respuesta del servidor
      // Asumimos que un código 200 indica éxito
      if (res.statusCode == 200) {
        // La API debe devolver una respuesta que indique éxito, 
        // a menudo simplemente devuelve un 200 o un booleano en el cuerpo.
        // Si el cuerpo de la respuesta es un booleano:
        // return res.data as bool; 

        // Si solo el código 200 indica éxito:
        return true; 
      }
      
      return false;
      
    } catch (e) {
      // Si hay un error de conexión, timeout o error 5xx del servidor
      debugPrint('Error en SubjectsDataSourceImpl.removeStudent: $e');
      throw Exception(e);
    }
  }
}
