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
  Future<void> updateSubject() {
    // TODO: implement updateSubject
    throw UnimplementedError();
  }

  @override
  // Future<List<StudentGroupSubject>> addStudentsSubject(int? groupId, int subjectId, List<String> emails) async {
  Future<List<StudentGroupSubject>> addStudentsSubject(
      int subjectId, List<String> emails) async {
    try {
      const uri = "/Alumnos/RegistrarAlumnoGMDocente";

      final res =
          await dio.post(uri, data: {"Emails": emails, "MateriaId": subjectId});

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
}
