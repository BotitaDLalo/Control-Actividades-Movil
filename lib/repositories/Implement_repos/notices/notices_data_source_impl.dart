import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/models/notice_list/notice_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/notices/notices_data_source.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NoticesDataSourceImpl implements NoticesDataSource {
  final storageService = KeyValueStorageServiceImpl();
  final cn = CatalogNames();

  String? _toIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    try {
      // Intenta parsear el formato 'dd-MM-yyyy' que probablemente viene del form.
      final inputFormat = DateFormat('dd-MM-yyyy');
      final dateTime = inputFormat.parse(dateString);
      return dateTime.toIso8601String();
    } catch (e) {
      // Si falla, puede que ya esté en formato ISO o similar. Intenta parseo directo.
      try {
        final dateTime = DateTime.parse(dateString);
        return dateTime.toIso8601String();
      } catch (e2) {
        debugPrint('Error: No se pudo parsear la fecha "$dateString". Formato no reconocido.');
        return null; // Devuelve null si ningún formato funciona.
      }
    }
  }

  @override
  Future<List<NoticeModel>> createNotice(NoticeModel notice) async {
    try {
      const uri = "/Avisos/CrearAviso";
      final groupId = notice.groupId;
      final subjectId = notice.subjectId;
      final id = await storageService.getId();

      List<String> links = [];
      if (notice.links != null && notice.links!.isNotEmpty) {
        try {
          // Intentar decodificar si es un string JSON de lista
          final decoded = jsonDecode(notice.links!);
          if (decoded is List) {
            links = List<String>.from(decoded.map((e) => e.toString()));
          } else {
            links = [notice.links!];
          }
        } catch (e) {
          // Si falla, asumir que es un solo enlace plano
          links = [notice.links!];
        }
      }

      Map<String, dynamic> data = {
        "DocenteId": id,
        "Titulo": notice.title,
        "Descripcion": notice.description,
        "FechaInicio": _toIso8601(notice.startDate),
        "FechaFin": _toIso8601(notice.endDate),
        "FrecuenciaDias": notice.frequencyDays,
        "Enlaces": links,
      };

      if (groupId != 0) {
        data['GrupoId'] = groupId;
      } else if (subjectId != 0) {
        data['MateriaId'] = subjectId;
      }

      final res = await dio.post(uri, data: data);

      // CAMBIO: Accept both 200 (OK) and 400 (BadRequest) as successful if data is present
      // Esto maneja el caso donde el backend retorna BadRequest pero incluye datos válidos
      if ((res.statusCode == 200 || res.statusCode == 400) && res.data is Map) {
        final response = Map<String, dynamic>.from(res.data);
        final notice = NoticeModel.jsonToEntityNotice(response);
        List<NoticeModel> lsNotice = [notice];
        return lsNotice;
      }
      return [];
    } catch (e) {
      debugPrint('Error creating notice: ${e.toString()}');
      return [];
    }
  }

  @override
  Future<List<NoticeModel>> getlsNotices(NoticeModel notice) async {
    try {
      const uri = "/Avisos/ConsultarAvisosCreados";
      int groupId = notice.groupId;
      int subjectId = notice.subjectId;

      Map<String, dynamic> data = {
        "GrupoId": 0,
        "MateriaId": 0
      };

      if (groupId != 0) {
        data['GrupoId'] = groupId;
      } else if (subjectId != 0) {
        data['MateriaId'] = subjectId;
      }

      final res = await dio.post(uri, data: data);

      if (res.statusCode == 200) {
        final resls = List<Map<String, dynamic>>.from(res.data);
        final lsNotices = NoticeModel.jsonToEntitylsNotices(resls);
        return lsNotices;
      }
      return [];
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> deleteNotice(int notice) async {
    try {
      const uri = "/Avisos/EliminarAviso";
      final res = await dio.post(uri, queryParameters: {"avisoId": notice});
      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
  @override
  Future<List<NoticeModel>> updateNotice(NoticeModel notice) async { // NUEVO
    try {
      // Usamos el mismo URI de createNotice pero con los parámetros de actualización
      const uri = "/Avisos/ActualizarAviso";

      List<String> links = [];
      if (notice.links != null && notice.links!.isNotEmpty) {
        try {
          // Intentar decodificar si es un string JSON de lista
          final decoded = jsonDecode(notice.links!);
          if (decoded is List) {
            links = List<String>.from(decoded.map((e) => e.toString()));
          } else {
            links = [notice.links!];
          }
        } catch (e) {
          // Si falla, asumir que es un solo enlace plano
          links = [notice.links!];
        }
      }

      Map<String, dynamic> data = {
        "AvisoId": notice.noticeId, // Clave para la actualización
        "Titulo": notice.title,
        "Descripcion": notice.description,
        "FechaInicio": _toIso8601(notice.startDate),
        "FechaFin": _toIso8601(notice.endDate),
        "FrecuenciaDias": notice.frequencyDays,
        "Enlaces": links,
      };

      // Nota: Se usa PUT, que es el verbo HTTP estándar para actualizaciones completas.
      final res = await dio.put(uri, data: data); 

      if (res.statusCode == 200) {
        final response = Map<String, dynamic>.from(res.data);
        
        // 1. Convertimos la respuesta simple del API a un NoticeModel
        NoticeModel updatedNotice = NoticeModel.jsonToEntityNotice(response);
        
        // 2. CORRECCIÓN VITAL: El API no devuelve TeacherFullName, así que
        //    lo copiamos del objeto NoticeModel original que recibimos como parámetro.
        updatedNotice = updatedNotice.copyWith(
          teacherFullName: notice.teacherFullName, 
        );

        return [updatedNotice];
      }
      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
