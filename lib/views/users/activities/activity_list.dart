import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/custom_alert_dialog.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';

class ActivityList extends ConsumerStatefulWidget {
  final int subjectId;
  final Widget Function()? emptyBuilder;
  const ActivityList({super.key, required this.subjectId, this.emptyBuilder});

  @override
  ConsumerState<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
  @override
  void initState() {
    Future.microtask(
      () {
        ref.read(activityProvider.notifier).clearSubmissionData();
        // ref.read(activityProvider.notifier).getAllActivities(widget.subjectId);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cn = ref.watch(catalogNamesProvider);
    final role = ref.watch(roleFutureProvider).maybeWhen(
          data: (role) => role,
          orElse: () => "",
        );

    final actls = ref.watch(activityProvider).lsActivities;
    final lsActivities = ref
        .read(activityProvider.notifier)
        .getActivitiesBySubject(widget.subjectId, actls);

    // final act = ref.watch(activityProvider);
    // final lsActivities = act.lsActivities
    //     .where((activity) => activity.materiaId == widget.subjectId)
    //     .toList();

    // print("Actividades 1 : ${lsActivities}");
    // print("Actividades 2 : ${lsActivities.length}");
    // print("filteredActivities ${filteredActivities.length}");

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
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            message: '¿Desea eliminar la actividad?',
            comment: 'Todas las entregas y calificaciones serán eliminadas',
            buttonCancelName: 'Cancelar',
            onPressedContinue: () async {
              await ref
                  .read(activityProvider.notifier)
                  .deleteActivity(activityId);

              closeDialog();
            },
            buttonContinueName: 'Eliminar',
            onPressedCancel: () => closeDialog(),
          );
        },
      );
    }

    void showModalBottomActivityOptions(int activityId) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialogDeleteConfirmation(activityId);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    if (lsActivities.isEmpty && widget.emptyBuilder != null) {
      return widget.emptyBuilder!();
    }
    return ListView.builder(
      itemCount: lsActivities.length,
      itemBuilder: (context, index) {
        final activity = lsActivities[index];
        return GestureDetector(
          onLongPress: () async {
            if (role == cn.getRoleTeacherName) {
              showModalBottomActivityOptions(activity.activityId!);
            }
          },
          child: ElementTile(
              icon: Icons.assignment,
              iconSize: 28,
              iconColor: Colors.white,
              title: activity.nombreActividad,
              subtitle: activity.fechaLimite.toString(),
              onTapFunction: () async {
                final activityData = Activity(
                    activityId: activity.activityId,
                    nombreActividad: activity.nombreActividad,
                    descripcion: activity.descripcion,
                    tipoActividadId: activity.tipoActividadId,
                    fechaCreacion: activity.fechaCreacion,
                    fechaLimite: activity.fechaLimite,
                    materiaId: activity.materiaId,
                    puntaje: activity.puntaje);
                if (role == cn.getRoleTeacherName) {
                  teacherActivityStudentsSubmissions(activityData);
                } else if (role == cn.getRoleStudentName) {
                  studentActivitySubmissions(activityData);
                }
              }),
        );
      },
    );
  }
}
