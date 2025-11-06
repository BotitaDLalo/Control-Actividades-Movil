import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/models/groups/group.dart';
import 'package:aprende_mas/models/subjects/subjects.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';
import 'package:aprende_mas/views/views.dart';

class EventDetailsStudentScreen extends ConsumerWidget {
  final Event event;

  const EventDetailsStudentScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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
              event.title,
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
    );
  }
}
