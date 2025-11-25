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
        final res = await dio.get(uri, queryParameters: {'docenteId': id});
        resList = List<Map<String, dynamic>>.from(res.data);
      } else if (role == cn.getRoleStudentName) {
        const uri = "/Grupos/ObtenerGruposMateriasAlumno";
        final res = await dio.get(uri, queryParameters: {'alumnoId': id});
        resList = List<Map<String, dynamic>>.from(res.data);
      }
      final groups = Group.groupsJsonToEntityList(resList);
      return groups;
    } catch (e) {
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

      final res = await dio.post(uri, data: {
        "DocenteId": id,
        "NombreGrupo": groupName,
        "Descripcion": description,
        "Materias": subList
      });

      if (res.statusCode == 200) {
        final resLista = List<Map<String, dynamic>>.from(res.data);
        final groups = Group.groupsJsonToEntityList(resLista);
        return groups;
      }
      return [];
    } catch (e) {
      print(e);
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
  Future<void> deleteGroup(int teacherId, int groupId) {
    // TODO: implement updateGroup
    throw UnimplementedError();
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
  Future<bool> removeStudentFromGroup({
    required int groupId, 
    required int studentId
  }) async {
    try {
      // Esta es la ruta que acabamos de crear en C#
      const uri = "/api/Alumnos/EliminarAlumnoGrupo"; 

      final res = await dio.post(
        uri, 
        data: {
          "GrupoId": groupId,
          "AlumnoId": studentId,
        }
      );

      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error en GroupsDataSourceImpl: $e');
      throw Exception(e);
    }
  }
}
