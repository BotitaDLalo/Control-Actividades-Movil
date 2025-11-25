import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/custom_alert_dialog.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:intl/intl.dart';


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
    final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss'); 

    final outputFormatter = DateFormat('dd \'de\' MMMM \'a las\' hh:mm a', 'es');

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

// AHORA RECIBE EL OBJETO ACTIVITY COMPLETO
    void showModalBottomActivityOptions(Activity activity) {
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
                    Navigator.pop(context); // Cierra el modal
                    
                    // Navega a la pantalla de formulario pasando la actividad actual
                    context.push('/create-activities', extra: activity); 
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialogDeleteConfirmation(activity.activityId!);
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
    
// En activity_list.dart
return ListView.builder(
  itemCount: lsActivities.length,
  itemBuilder: (context, index) {
    final activity = lsActivities[index];
    
    // --- CORRECCIÓN DEL ERROR DE FORMATO ---
    String formattedDate = activity.fechaLimite.toString();

    try {
        // A. Convertir la cadena original (ej: "24-11-2025 12:00:00") a un DateTime
        final DateTime dateToFormat = inputFormatter.parse(activity.fechaLimite.toString()); 

        // B. Formatear el objeto DateTime al nuevo formato de salida
        formattedDate = outputFormatter.format(dateToFormat); 
    } catch (e) {
        // En caso de error, usamos la fecha original o un mensaje de error.
        print('Error al parsear o formatear la fecha: $e'); 
        // Si el parsing falla, usamos la cadena original como fallback
        formattedDate = activity.fechaLimite.toString(); 
    }
    // ------------------------------------
    
    return ElementTile(
        icon: Icons.assignment,
        iconSize: 28,
        iconColor: Colors.white,
        title: activity.nombreActividad,
        
        // Usamos la fecha correctamente formateada
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
              puntaje: activity.puntaje);
          if (role == cn.getRoleTeacherName) {
            teacherActivityStudentsSubmissions(activityData);
          } else if (role == cn.getRoleStudentName) {
            studentActivitySubmissions(activityData);
          }
        });
  },
);
  }
}
