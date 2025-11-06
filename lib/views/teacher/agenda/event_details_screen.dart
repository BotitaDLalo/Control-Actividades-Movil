import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/models/groups/group.dart';
import 'package:aprende_mas/models/subjects/subjects.dart';
import 'package:aprende_mas/providers/agenda/event_provider.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';
import 'package:aprende_mas/views/views.dart';

class EventDetailsScreen extends ConsumerWidget {
  final Event event;
  final int eventId;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.eventId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final eventState = ref.watch(eventProvider);

    // Buscar el evento específico
    final eventOnly = eventState.events.firstWhere(
      (event) => event.eventId == eventId,
    );

    final eventNotifier = ref.watch(eventProvider.notifier);

    final groupProvider = ref.watch(groupsProvider);
    final subjectProvider = ref.watch(subjectsProvider);

    int? groupId = event.groupIds?.isNotEmpty == true ? event.groupIds!.first : null;

    int? subjectId = event.subjectIds?.isNotEmpty == true ? event.subjectIds!.first : null;

    String? groupName = groupId != null
      ? groupProvider.lsGroups.firstWhere(
          (g) => g.grupoId == groupId,
          orElse: () => Group(grupoId: groupId, nombreGrupo: "Grupo no encontrado"),
        ).nombreGrupo
      : null;

    String? subjectName = subjectId != null
      ? subjectProvider.lsSubjects.firstWhere(
          (s) => s.materiaId == subjectId,
          orElse: () => Subject(materiaId: subjectId, nombreMateria: "Materia no encontrada"),
        ).nombreMateria
      : null;

    Future<bool?> showDeleteConfirmationDialog(BuildContext context) async {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Eliminar Evento"),
          content:
              const Text("¿Estás seguro de que deseas eliminar este evento?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AppBarScreens(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              eventOnly.title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),

            const Text(
              'Inicia: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(formatOnlyDate(event.startDate)),
                      const SizedBox(
                        width: 90,
                      ),
                      Text(formatOnlyTime(event.startDate)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Finaliza: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(formatOnlyDate(event.endDate)),
                      const SizedBox(
                        width: 90,
                      ),
                      Text(formatOnlyTime(event.endDate)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Destinatario: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (groupName != null) Text("Grupo: $groupName"),
            if (subjectName != null) Text("Materia: $subjectName"),
            if (groupName == null && subjectName == null)
            const Text("Este evento no está asignado a ningún grupo ni materia."),

            const SizedBox(
              height: 20,
            ),
            const Text(
              'Descripción: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(event.description),
            // Text(groupIds.toString() ?? subjectIds.toString()),
            // Text(subjectIds.toString())
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'updateEvent',
            onPressed: () {
              final eventData = Event(
                eventId: event.eventId,
                teacherId: event.teacherId,
                title: event.title,
                description: event.description,
                startDate: event.startDate,
                endDate: event.endDate,
                color: event.color,
                groupIds: event.groupIds, // Si es null, se mantiene null
                subjectIds: event.subjectIds, // Si es null, se mantiene null
              );
              context.push('/update-event', extra: eventData);
              ref.read(eventProvider.notifier).getEvents();
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              final confirm = await showDeleteConfirmationDialog(context);

              if (confirm == true) {
                try {
                  // Llamar al método deleteEvent del EventNotifier
                  await eventNotifier.deleteEvent(
                      event.teacherId, event.eventId!);
                  // Mostrar un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Evento eliminado correctamente")),
                  );

                  // Navegar de regreso a la pantalla anterior
                  context.pop();
                  ref.read(eventProvider.notifier).getEvents();
                } catch (e) {
                  // Mostrar un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al eliminar el evento: $e")),
                  );
                }
              }
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
