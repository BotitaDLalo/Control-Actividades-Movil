import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/providers/agenda/event_provider.dart';
import 'package:aprende_mas/views/widgets/calendar/event_calendar_data_source.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class CalendarBody extends ConsumerStatefulWidget {
  const CalendarBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<CalendarBody> {
  CalendarView calendarView = CalendarView.month; // Vista predeterminada
  CalendarController calendarController = CalendarController();
   late EventCalendarDataSource calendarDataSource;

  final cn = CatalogNames();
  final kvs = KeyValueStorageServiceImpl();
  late String role = "";

    final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule,
  ];

@override
void initState() {
  super.initState();
  calendarDataSource = EventCalendarDataSource([]);
  getRole();
}

Future<void> getRole() async {
  final userRole = await kvs.getRole();
  setState(() {
    role = userRole;
  });

  Future.microtask(() async {
    if (role == cn.getRoleTeacherName) {
      await ref.read(eventProvider.notifier).getEvents(); // 🔹 Cargar eventos de docentes
      final teacherEvents = ref.read(eventProvider).events; // 🔹 Obtener eventos actualizados
      calendarDataSource.updateEvents(teacherEvents); // 🔹 Actualizar UI solo para docentes
    } else if (role == cn.getRoleStudentName) {
      await ref.read(eventProvider.notifier).getEventsStudent(); // 🔹 Cargar eventos de alumnos (pero sin actualizar la UI)
    }
  });
}


  @override
  Widget build(BuildContext context) {

    // Obtener el estado global de eventos
    // final eventState = ref.watch(eventProvider);

    ref.listen(eventProvider, (previous, next) {
    calendarDataSource.updateEvents(next.events);
  });


    return Scaffold(
    body: Column(
      children: [
        Expanded(
          child: SfCalendar(
            allowedViews: _allowedViews,
            cellBorderColor: Colors.transparent,
            dataSource: calendarDataSource,
            controller: calendarController,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
              showAgenda: true,
              dayFormat: 'EEE',
              numberOfWeeksInView: 6,
            ),
            headerStyle: const CalendarHeaderStyle(
              backgroundColor: Color.fromARGB(255, 199, 240, 249),
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            todayHighlightColor: const Color(0xFF0FA4E0),
            selectionDecoration: BoxDecoration(
              color: const Color.fromARGB(30, 15, 164, 224),
              border: Border.all(color: const Color(0xFF0FA4E0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            view: calendarView,
            showDatePickerButton: true,
            onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment &&
                details.appointments != null) {
              final Event selectedEvent = details.appointments!.first as Event;
              
              // 🔹 Condicional para seleccionar la ruta correcta según el rol
              final String route = (role == cn.getRoleTeacherName) 
                ? '/event-detail' 
                : '/event-detail-student';

              context.push(route, extra: selectedEvent);
            }
            },
          ),
        ),
      ],
    ),
    floatingActionButton: role == cn.getRoleTeacherName
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/create-event');
                ref.read(eventProvider.notifier).getEvents();
              },
              backgroundColor: Colors.blue,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null, // No muestra el botón si no es docente
  );
}
}




  