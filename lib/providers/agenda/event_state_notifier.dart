import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/providers/agenda/event_state.dart';
import 'package:aprende_mas/repositories/Interface_repos/agenda/event_repository.dart';
import 'package:aprende_mas/views/widgets/calendar/event_calendar_data_source.dart';

class EventNotifier extends StateNotifier<EventState>{
  final EventRepository eventRepository;
  final EventCalendarDataSource calendarDataSource;

  EventNotifier({required this.eventRepository, required this.calendarDataSource}) : super(EventState());

  Future<void> getEvents() async {
    try {
      final events = await eventRepository.getEvents();
      _setEvents(events);
      debugPrint("Estado actualizado con eventos: ${state.events}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _setEvents(List<Event> events) {
    state = state.copyWith(events: events);
  }

    Future<void> getEventsStudent() async {
    try {
      final events = await eventRepository.getEventsStudent();
      _setEventsStudent(events);
      debugPrint("Estado actualizado con eventos: ${state.events}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _setEventsStudent(List<Event> events) {
    state = state.copyWith(events: events);
  }

  Future<void> createEvents(
    String title,
    String description,
    Color color,
    DateTime startDate,
    DateTime endDate, {
    List<int>? groupIds,
    List<int>? subjectIds,
}) async{
    
    try {
      state = state.copyWith(isLoading: true);
      final event = await eventRepository.createEvent(
        title,
        description,
        color,
        startDate,
        endDate,
        groupIds: groupIds,
        subjectIds: subjectIds);
      _setCreateEvent(event);
    } catch (e) {
     state = state.copyWith(errorMessage: e.toString()); 
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  _setCreateEvent(List<Event> event) {
    state = state.copyWith(events: event);
  }

  Future<void> updateEvents(Map<String, dynamic> eventLike) async{
    
    try {
      state = state.copyWith(isLoading: true);
      final event = await eventRepository.updateEvent(eventLike);
      _setupdateEvent(event);
    } catch (e) {
     state = state.copyWith(errorMessage: e.toString()); 
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // _setupdateEvent(Event event) {
  //   state = state.copyWith(event: event );
  // }

  void _setupdateEvent(Event event) {
  final updatedEvents = state.events.map((e) => e.eventId == event.eventId ? event : e).toList();
  state = state.copyWith(event: event, events: updatedEvents);
}


  Future<void> deleteEvent(int teacherId, int eventId) async {
  try {
    state = state.copyWith(isLoading: true);

    // Llamada al repositorio para eliminar el evento
    final updatedEvents = await eventRepository.deleteEvent(teacherId, eventId);
    
    // Actualizar el estado global con la lista de eventos actualizada
    _setDeleteEvent(updatedEvents);
    
    // Actualizar calendarDataSource
    calendarDataSource.updateEvents(updatedEvents);

  } catch (e) {
    state = state.copyWith(errorMessage: e.toString());
  }
}

// Función para actualizar el estado de los eventos
_setDeleteEvent(List<Event> updatedEvents) {
  state = state.copyWith(events: updatedEvents);
  calendarDataSource.updateEvents(updatedEvents); // Se llama solo una vez
}



}
