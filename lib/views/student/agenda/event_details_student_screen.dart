import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/models/groups/group.dart';
import 'package:aprende_mas/models/subjects/subjects.dart';
import 'package:aprende_mas/providers/agenda/event_provider.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';

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
      appBar: AppBarHome(title: 'Detalles del Evento', showSettings: false, leading: IconButton(icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 30, height: 30, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del evento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF086E9A), Color(0xFF17B7F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Card para fechas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Fechas del Evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inicio',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(formatOnlyDate(event.startDate)),
                              Text(
                                formatOnlyTime(event.startDate),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.stop, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fin',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(formatOnlyDate(event.endDate)),
                              Text(
                                formatOnlyTime(event.endDate),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card para destinatario
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Destinatario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    if (groupName != null)
                      Row(
                        children: [
                          const Icon(Icons.group_work, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text("Grupo: $groupName"),
                        ],
                      ),
                    if (subjectName != null)
                      Row(
                        children: [
                          const Icon(Icons.book, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text("Materia: $subjectName"),
                        ],
                      ),
                    if (groupName == null && subjectName == null)
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Este evento no está asignado a ningún grupo ni materia.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card para descripción
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // Espacio para los FABs
          ],
        ),
      ),
    );
  }
}
