import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:intl/intl.dart';

class ActivityList extends ConsumerStatefulWidget {
  final int subjectId;
  final String nombreMateria;
  final Widget Function()? emptyBuilder;

  const ActivityList({
    super.key,
    required this.subjectId,
    required this.nombreMateria,
    this.emptyBuilder,
  });

  @override
  ConsumerState<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    Future.microtask(() {
      ref.read(activityProvider.notifier).clearSubmissionData();
      _searchController.addListener(_onSearchChanged);
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(activitySearchTermProvider.notifier).state =
        _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final cn = ref.watch(catalogNamesProvider);

    final role = ref.watch(roleFutureProvider).maybeWhen(
          data: (role) => role,
          orElse: () => "",
        );

    final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    final outputFormatter =
        DateFormat("dd 'de' MMMM 'a las' hh:mm a", 'es');

    final activitiesAsync =
        ref.watch(filteredActivitiesProvider(widget.subjectId));

    final subjectColor = getSubjectColor(widget.subjectId);

    void teacherActivityStudentsSubmissions(Activity activity) {
      context.push('/teacher-activities-students-options', extra: activity);
    }

    void studentActivitySubmissions(Activity activity) {
      context.push('/student-activity-section-submissions', extra: activity);
    }

    void closeDialog() {
      Navigator.of(context).pop();
    }

    void showDialogDeleteConfirmation(int activityId) {
      WarningConfirmationDialog.show(
        context,
        message: '¿Desea eliminar la actividad? Todas las entregas y calificaciones serán eliminadas',
        onConfirmPressed: () async {
          await ref
              .read(activityProvider.notifier)
              .deleteActivity(activityId);
 
          ref.invalidate(
              activitiesBySubjectProvider(widget.subjectId));
        },
      );
    }

    void showModalBottomActivityOptions(Activity activity) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/icons/edit2.svg', width: 24, height: 24),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);

                    final subjectDataWithActivity = Subject(
                      activity: activity,
                      materiaId: widget.subjectId,
                      nombreMateria: widget.nombreMateria,
                    );

                    context.push(
                      '/create-activities',
                      extra: subjectDataWithActivity,
                    );
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset('assets/icons/eliminar1.svg', width: 24, height: 24),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialogDeleteConfirmation(activity.activityId!);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: '  Buscar actividades',
              prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
              prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn))),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: subjectColor, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
          ),

          const SizedBox(height: 8),

      SizedBox(
        // Hace que el ListView interno funcione bien
        height: MediaQuery.of(context).size.height * 0.75,
        child: activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) =>
              const Center(child: Text('Error al cargar actividades.')),
          data: (lsActivities) {
            if (lsActivities.isEmpty) {
              final searchTerm = ref.watch(activitySearchTermProvider);

              if (searchTerm.isNotEmpty) {
                return const Center(
                  child: Text('No hay actividades que coincidan con la búsqueda.'),
                );
              }

              if (widget.emptyBuilder != null) {
                return widget.emptyBuilder!();
              }
            }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: lsActivities.length,
                itemBuilder: (context, index) {
                  final activity = lsActivities[index];

                  String formattedDate =
                      activity.fechaLimite.toString();

                  try {
                    final dateToFormat = inputFormatter.parse(
                        activity.fechaLimite.toString());
                    formattedDate =
                        outputFormatter.format(dateToFormat);
                  } catch (e) {
                    formattedDate = activity.fechaLimite.toString();
                  }

                  return ElementTile(
                    iconWidget: SvgPicture.asset('assets/icons/act1.svg', width: 40, height: 40),
                    iconSize: 40,
                    iconColor: Colors.black,
                    title: activity.nombreActividad,
                    subtitle: formattedDate,
                    trailingWidget: role == cn.getRoleTeacherName
                        ? IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: Colors.grey,
                            onPressed: () {
                              showModalBottomActivityOptions(activity);
                            },
                          )
                        : null,
                    onTapFunction: () async {
                      final activityData = Activity(
                        activityId: activity.activityId,
                        nombreActividad: activity.nombreActividad,
                        descripcion: activity.descripcion,
                        tipoActividadId: activity.tipoActividadId,
                        fechaCreacion: activity.fechaCreacion,
                        fechaLimite: activity.fechaLimite,
                        materiaId: activity.materiaId,
                        puntaje: activity.puntaje,
                      );

                      if (role == cn.getRoleTeacherName) {
                        teacherActivityStudentsSubmissions(activityData);
                      } else if (role == cn.getRoleStudentName) {
                          studentActivitySubmissions(activityData);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
