import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/groups_subjects/groups_subjects_data_source.dart';

class GroupsSubjectsDataSourceImpl implements GroupsSubjectsDataSource {
  final storageService = KeyValueStorageServiceImpl();

  @override
  Future<JoinClass> joinClass(String codeClass) async {
    try {
      const uri = "/Alumnos/UnirseAClaseM";

      final studentId = await storageService.getId();

      // Convertir código a mayúsculas para hacer case-insensitive
      final normalizedCode = codeClass.toUpperCase();

      // 📤 LOGGING: Datos enviados al backend
      debugPrint("📤 [JOIN CLASS] Enviando petición:");
      debugPrint("📤 URL: ${dio.options.baseUrl}$uri");
      debugPrint("📤 Método: POST");
      debugPrint("📤 Datos: ${{"AlumnoId": studentId, "CodigoAcceso": normalizedCode}}");
      debugPrint("📤 Código original: '$codeClass' → Normalizado: '$normalizedCode'");

      final res = await dio.post(
        uri,
        data: {"AlumnoId": studentId, "CodigoAcceso": normalizedCode},
        options: Options(
          validateStatus: (status) => true, // Aceptar cualquier status code
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      // 📥 LOGGING: Respuesta del backend
      debugPrint("📥 [JOIN CLASS] Respuesta recibida:");
      debugPrint("📥 Status Code: ${res.statusCode}");
      debugPrint("📥 Headers: ${res.headers.map}");
      debugPrint("📥 Raw Response: ${res}");
      debugPrint("📥 Data: ${res.data}");
      debugPrint("📥 Data Type: ${res.data?.runtimeType}");
      debugPrint("📥 Data Keys: ${(res.data as Map?)?.keys.toList() ?? 'N/A'}");

      // Verificar el código de estado HTTP
      if (res.statusCode == 200) {
        final resMap = Map<String, dynamic>.from(res.data);
        debugPrint("✅ [JOIN CLASS] Status 200 - Verificando formato de respuesta...");

        // Respuesta completa normal
        debugPrint("🔄 [JOIN CLASS] Intentando parsear respuesta completa...");
        final response = JoinClass.resJsonToEntity(resMap);
        debugPrint("✅ [JOIN CLASS] Parseo exitoso: $response");
        return response;
      } else if (res.statusCode == 409) {
        // 409 Conflict - Alumno ya registrado
        final resMap = Map<String, dynamic>.from(res.data);
        final mensaje = resMap['mensaje'] as String? ?? 'Ya estás registrado en esta clase';
        debugPrint("⚠️ [JOIN CLASS] Status 409 - Alumno ya registrado: $mensaje");
        throw Exception("Ya estás registrado: $mensaje");
      } else if (res.statusCode == 404) {
        // 404 Not Found - Código inválido o docente no encontrado
        final resMap = Map<String, dynamic>.from(res.data);
        final mensaje = resMap['mensaje'] as String? ?? 'Código inválido o inexistente';
        debugPrint("❌ [JOIN CLASS] Status 404 - Código inválido: $mensaje");
        throw Exception("Código inválido: $mensaje");
      } else if (res.statusCode == 400) {
        // 400 Bad Request - Datos inválidos
        final resMap = Map<String, dynamic>.from(res.data);
        final mensaje = resMap['mensaje'] as String? ?? 'Datos de solicitud inválidos';
        debugPrint("❌ [JOIN CLASS] Status 400 - Datos inválidos: $mensaje");
        throw Exception("Datos inválidos: $mensaje");
      } else if (res.statusCode == 500 && res.data != null) {
        debugPrint("⚠️ [JOIN CLASS] Status 500 - Verificando si contiene datos válidos...");

        // Verificar si la respuesta tiene la estructura esperada
        final resMap = Map<String, dynamic>.from(res.data);

        // Si contiene un mensaje de error en lugar de datos válidos
        if (resMap.containsKey('Message') || resMap.containsKey('message')) {
          final errorMessage = resMap['Message'] ?? resMap['message'] ?? 'Error del servidor';
          debugPrint("❌ [JOIN CLASS] Respuesta contiene mensaje de error: $errorMessage");
          throw Exception("Error del servidor: $errorMessage");
        }

        // Verificar si tiene la estructura esperada (Grupo/Materia/EsGrupo)
        if (resMap.containsKey('EsGrupo') && (resMap.containsKey('Grupo') || resMap.containsKey('Materia'))) {
          try {
            debugPrint("🔄 [JOIN CLASS] Intentando parsear respuesta 500 con datos válidos...");
            final response = JoinClass.resJsonToEntity(resMap);
            debugPrint("✅ [JOIN CLASS] Parseo exitoso despite 500: $response");
            return response;
          } catch (parseError) {
            debugPrint("❌ [JOIN CLASS] Error al parsear respuesta 500: $parseError");
            throw Exception("Error del servidor al procesar la respuesta");
          }
        } else {
          debugPrint("❌ [JOIN CLASS] Respuesta 500 no tiene estructura esperada");
          throw Exception("Error del servidor al unirse a la clase");
        }
      } else {
        debugPrint("❌ [JOIN CLASS] Status code inesperado: ${res.statusCode}");
        throw Exception("Error ${res.statusCode}: ${res.data}");
      }
    } on DioException catch (e) {
      debugPrint("🚨 [JOIN CLASS] DioException: ${e.message}");
      debugPrint("🚨 [JOIN CLASS] Request: ${e.requestOptions?.method} ${e.requestOptions?.path}");
      debugPrint("🚨 [JOIN CLASS] Response: ${e.response?.statusCode} ${e.response?.data}");

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (statusCode == 409) {
        // 409 Conflict - Alumno ya registrado
        final resMap = responseData is Map ? Map<String, dynamic>.from(responseData) : {};
        final mensaje = resMap['mensaje'] as String? ?? 'Ya estás registrado en esta clase';
        throw Exception(mensaje);
      } else if (statusCode == 404) {
        // 404 Not Found - Código inválido o docente no encontrado
        final resMap = responseData is Map ? Map<String, dynamic>.from(responseData) : {};
        final mensaje = resMap['mensaje'] as String? ?? 'Código inválido o inexistente';
        throw Exception(mensaje);
      } else if (statusCode == 400) {
        // 400 Bad Request - Datos inválidos
        final resMap = responseData is Map ? Map<String, dynamic>.from(responseData) : {};
        final mensaje = resMap['mensaje'] as String? ?? 'Datos de solicitud inválidos';
        throw Exception(mensaje);
      } else if (statusCode == 500) {
        final errorMessage = responseData?['Message'] ??
                           responseData?['message'] ??
                           responseData?['error'] ??
                           "Error interno del servidor";
        throw Exception("Error del servidor: $errorMessage");
      }
      throw Exception("Error de conexión: ${e.message}");
    } catch (e) {
      debugPrint("🚨 [JOIN CLASS] Error inesperado: $e");
      // Re-throw exceptions que ya contienen mensajes específicos del backend
      if (e.toString().contains('Ya estás registrado') ||
          e.toString().contains('Código inválido') ||
          e.toString().contains('Datos inválidos') ||
          e.toString().contains('Error del servidor')) {
        rethrow;
      }
      // Para errores realmente inesperados
      throw Exception("Error inesperado al unirse a la clase");
    }
  }
}
