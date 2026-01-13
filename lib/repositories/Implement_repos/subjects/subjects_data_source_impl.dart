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
        final res = await dio.get(uri, queryParameters: {'docenteId': id});
        resList = List<Map<String, dynamic>>.from(res.data);
        debugPrint("SubjectsDataSourceImpl: ${res.data}");
      } else if (role == cn.getRoleStudentName) {
        const uri = "/Materias/ObtenerMateriasAlumno";
        final res = await dio.get(uri, queryParameters: {'alumnoId': id});
        resList = List<Map<String, dynamic>>.from(res.data);
      }
      
      final lsSubjects = Subject.subjectsJsonToEntityList(resList);
      return lsSubjects;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Group>> createSubjectWithGroup(String subjectName,
      String description, Color colorCode, List<int> groupsId) async {
    try {
      const uri = "/Materias/CrearMateriaGrupos";
      final id = await storageService.getId();
      final res = await dio.post(uri, data: {
        "NombreMateria": subjectName,
        "Descripcion": description,
        // "CodigoColor": colorCode.toString(),
        "DocenteId": id,
        "Grupos": groupsId
      });

      final resList = List<Map<String, dynamic>>.from(res.data);
      final groups = Group.groupsJsonToEntityList(resList);
      return groups;
    } catch (e) {
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
  Future<void> deleteSubject() {
    // TODO: implement deleteSubject
    throw UnimplementedError();
  }

  @override
  Future<void> updateSubject() {
    // TODO: implement updateSubject
    throw UnimplementedError();
  }


@override
Future<List<StudentGroupSubject>> addStudentsSubject(
    int subjectId, List<String> emails) async {
  
// 1. Obtener el docenteId desde el almacenamiento
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
      "DocenteId": docenteId 
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
      final errorData = e.response?.data;
      final serverMessage = errorData?['mensaje'] ?? 'Error desconocido del servidor.';
      throw Exception(serverMessage);
    }
    
    debugPrint('Error general de la API al asignar alumnos: $statusCode');
    throw Exception('Error en la conexión o servidor.');
    
  } catch (e) {
    throw Exception(e); 
  }
}

  @override
  Future<List<StudentGroupSubject>> getStudentsSubject(int? groupId,int subjectId) async {
    try {
      const uri = "/Alumnos/ObtenerListaAlumnosMateria";
      final res = await dio.post(uri, data: {
      "GrupoId": groupId ?? 0, 
      "MateriaId": subjectId 
    });

      if (res.statusCode == 200) {
        final resList = List<Map<String, dynamic>>.from(res.data);

          if (resList.isNotEmpty) {
              debugPrint('--- JSON DE UN ALUMNO RECIBIDO DEL SERVIDOR ---');
              debugPrint(resList.first.toString()); 
              debugPrint('----------------------------------------------');
          }


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
Future<bool> removeStudentFromSubject({
  required int alumnoMateriaId,
}) async {
    try {
        debugPrint('--- [DEBUG ELIMINACIÓN] ---');
        debugPrint('AlumnoMateriaId: $alumnoMateriaId');
        debugPrint('---------------------------');
        debugPrint('BODY ENVIADO: ${{
          'AlumnoMateriaId': alumnoMateriaId,
        }}');

        
        const uri = "/Alumnos/EliminarAlumnoMateria"; 

        final res = await dio.post(
            uri, 
            data: {
            'AlumnoMateriaId': alumnoMateriaId,
            }
        );

        if (res.statusCode == 200) {
            return true;
        }
        
        return false; 

    } catch (e) {
        // Si hay una excepción de red (DioException), se registra y se relanza.
        debugPrint('Error en SubjectsDataSourceImpl.removeStudentFromSubject: $e');
        
        throw Exception(e); 
    }
}
}
