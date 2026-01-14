import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_mapper.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/repositories/Interface_repos/agenda/event_data_source.dart';

class EventDataSourceImpl implements EventDataSource {
  final storageService = KeyValueStorageServiceImpl();

  @override
  Future<List<Event>> getEvents() async {
    try {
      final id = await storageService.getId();
      const uri = "/EventosAgenda/ObtenerEventos";
      final res = await dio.get(uri, queryParameters: {'docenteId': id});
      debugPrint("Respuesta del backend: ${res.data}");

      final List<Map<String, dynamic>> responseList =
          List<Map<String, dynamic>>.from(res.data);

      return EventMapper.fromMapList(responseList);
    } catch (e) {
      throw Exception("Error al obtener eventos: $e");
    }
  }

  @override
  Future<List<Event>> createEvent(
    String title,
    String description,
    Color color,
    DateTime startDate,
    DateTime endDate, {
    List<int>? groupIds,
    List<int>? subjectIds,
  }) async {
    try {
      const uri = "/EventosAgenda/CrearEventos";
      final String hexColor =
          color.value.toRadixString(16).substring(2).toUpperCase();
      final teacherId = await storageService.getId();
  
      final response = await dio.post(uri, data: {
        "DocenteId": teacherId, // Incluimos el ID del docente automáticamente
        "FechaInicio": startDate.toIso8601String(),
        "FechaFinal": endDate.toIso8601String(),
        "Titulo": title,
        "Descripcion": description,
        "Color": hexColor,
        "EventosGrupos": groupIds?.map((id) => {"GrupoId": id}).toList(),
        "EventosMaterias": subjectIds?.map((id) => {"MateriaId": id}).toList(),
      });
  
      print("🔹 Respuesta del backend al crear evento: ${response.data}");
  
      // Manejar diferentes tipos de respuesta del backend
      if (response.data is Map && response.data.containsKey('Message')) {
        print("🔹 Respuesta es un mensaje de éxito, obteniendo datos actualizados...");
        // Si el backend devuelve solo un mensaje, obtener los datos actualizados
        final res = await dio.get("/EventosAgenda/ObtenerEventos", queryParameters: {'docenteId': teacherId});
        print("🔹 Respuesta de ObtenerEventos: ${res.data}");
  
        if (res.data != null && res.data is List) {
          final List<Map<String, dynamic>> responseList = List<Map<String, dynamic>>.from(res.data);
          final events = EventMapper.fromMapList(responseList);
          print("🔹 Eventos obtenidos después de creación: $events");
          return events;
        } else {
          print("❌ Error: La respuesta de ObtenerEventos es nula o no es una lista");
          return []; // Devolver lista vacía en lugar de null
        }
      } else if (response.data != null) {
        // Si el backend devuelve datos de evento directamente
        try {
          final List<Map<String, dynamic>> resList = List<Map<String, dynamic>>.from(response.data);
          final events = EventMapper.fromMapList(resList);
          print("🔹 Eventos creados: $events");
          return events;
        } catch (e) {
          print("❌ Error al convertir respuesta a lista de eventos: $e");
          return []; // Devolver lista vacía en caso de error
        }
      } else {
        print("❌ Error: La respuesta del backend es nula");
        return []; // Devolver lista vacía en lugar de null
      }
    } catch (e) {
      print("❌ Error en createEvent: $e");
      return []; // Devolver lista vacía en caso de excepción
    }
  }

  @override
  Future<Event> updateEvent(Map<String, dynamic> eventLike) async {
    try {
      print("🔹 Iniciando updateEvent con datos: $eventLike");

      final int? eventId = eventLike['eventoId'] as int?;
      print("🔹 eventId obtenido: $eventId (tipo: ${eventId?.runtimeType})");

      if (eventId == null) {
        print("❌ Error: eventoId es nulo");
        throw Exception("eventoId no puede ser nulo");
      }

      final String method = 'PATCH';
      final url = "/EventosAgenda/ActualizarEvento/$eventId";
      print("🔹 URL de actualización: $url");
      print("🔹 Método: $method");

      final eventLikeCopy = Map<String, dynamic>.from(eventLike);
      eventLikeCopy.remove('eventoId');
      print("🔹 Datos a enviar: $eventLikeCopy");

      final response = await dio.request(url,
          data: eventLikeCopy, options: Options(method: method));
      print("🔹 Respuesta del servidor: ${response.data}");

      // Manejar diferentes tipos de respuesta del backend
      if (response.data is Map && response.data.containsKey('Message')) {
        print("🔹 Respuesta es un mensaje de éxito, obteniendo datos actualizados...");
        // Si el backend devuelve solo un mensaje, obtener los datos actualizados
        final teacherId = await storageService.getId();
        final res = await dio.get("/EventosAgenda/ObtenerEventos", queryParameters: {'docenteId': teacherId});
        final List<Map<String, dynamic>> responseList = List<Map<String, dynamic>>.from(res.data);
        final events = EventMapper.fromMapList(responseList);
        final updatedEvent = events.firstWhere((event) => event.eventId == eventId);
        print("🔹 Evento actualizado obtenido: $updatedEvent");
        return updatedEvent;
      } else {
        // Si el backend devuelve datos de evento directamente
        final updatedEvent = EventMapper.jsonToEntity(response.data);
        print("🔹 Evento actualizado: $updatedEvent");
        return updatedEvent;
      }
    } catch (e) {
      print("❌ Excepción en updateEvent: $e");
      print("❌ Tipo de excepción: ${e.runtimeType}");
      if (e is Exception) {
        print("❌ Mensaje de excepción: ${e.toString()}");
      }
      throw Exception("Error en updateEvent: $e");
    }
  }

  @override
  Future<List<Event>> deleteEvent(int teacherId, int eventId) async {
    try {
      final teacherId = await storageService.getId();
      const uri = "/EventosAgenda/EliminarEvento";

      final response = await dio.delete(uri, queryParameters: {
        "docenteId": teacherId,
        "eventoId": eventId,
      });

      final resList = List<Map<String, dynamic>>.from(response.data);
      final events = EventMapper.fromMapList(resList);

      return events;
    } catch (e) {
      throw Exception("Error en deleteEvent: $e");
    }
  }

  @override
  Future<List<Event>> getEventsStudent() async {
    try {
      final id = await storageService.getId();
      const uri = "/EventosAgenda/ObtenerEventosAlumno";
      final res = await dio.get(uri, queryParameters: {'alumnoId': id});
      debugPrint("Respuesta del backend: ${res.data}");

      final List<Map<String, dynamic>> responseList =
          List<Map<String, dynamic>>.from(res.data);

      return EventMapper.fromMapList(responseList);
    } catch (e) {
      throw Exception("Error al obtener eventos: $e");
    }
  }
}
