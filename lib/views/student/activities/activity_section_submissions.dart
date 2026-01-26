import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/config/utils/utils.dart';

final hasSubmissionsProvider = StateProvider(
  (ref) => false,
);

class ActivitySectionSubmissions extends ConsumerStatefulWidget {
  final Activity activity;
  const ActivitySectionSubmissions({super.key, required this.activity});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActivitySectionSubmissionState();
}

class _ActivitySectionSubmissionState
    extends ConsumerState<ActivitySectionSubmissions> {
  void showDialogAnswer(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => DialogTextField(
        answer: content,
        buttonName: "Modificar",
      ),
    );
  }

  void showModalTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DialogTextField(
        buttonName: 'Agregar',
      ),
    );
  }

  void showModalActivityType(
    BuildContext context,
  ) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/icons/activities20.svg', width: 24, height: 24),
                  title: const Text('Agregar Respuesta'),
                  onTap: () {
                    Navigator.pop(context);
                    showModalTextField(context);
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.description),
                //   title: const Text('Agregar Archivo'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     // context.push('/create-group');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.link),
                //   title: const Text('Agregar Enlace'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     // context.push('/create-subject');
                //   },
                // ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final authConectionType = ref.read(authProvider).authConectionType;
    final activityId = widget.activity.activityId;
    final activitiesForm = ref.watch(activityFormProvider);
    final lsSub = ref.watch(activityProvider).lsSubmissions;
    final lsSubmissions = Submission.activitiesBySubject(lsSub, activityId!);

    // final lsSubmissions = ref
    //     .read(activityProvider.notifier)
    //     .getSubmissionsByActivity(activityId);

    void showSendConfirmation() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Enviar',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          content: const Text('¿Quiere realizar el envio?'),
          contentPadding: const EdgeInsets.all(10),
          actions: [
            TextButton(
                onPressed: () {
                  print('Intentando enviar respuesta: ${activitiesForm.answer}');
                  if (authConectionType == AuthConnectionType.online) {
                    ref
                        .read(activityFormProvider.notifier)
                        .onSendSubmission(activityId);
                  } else if (authConectionType == AuthConnectionType.offline) {
                    ref
                        .read(activityFormProvider.notifier)
                        .onSendSubmissionOffline(activityId);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Enviar'))
          ],
        ),
      );
    }

    void showModalBottomDropAnswer(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/icons/eliminar1.svg', width: 24, height: 24),
                  title: const Text('Eliminar respuesta'),
                  onTap: () {
                    ref.read(activityFormProvider.notifier).dropAnswer();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    void showModalBottomCancelSubmit(int studentActivityId) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/icons/eliminar1.svg', width: 24, height: 24),
                  title: const Text('Cancelar Entregable'),
                  onTap: () {
                    if (authConectionType == AuthConnectionType.online) {
                      ref.read(activityProvider.notifier).cancelSubmission(
                          studentActivityId, widget.activity.activityId!);
                    } else if (authConectionType ==
                        AuthConnectionType.offline) {}

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    void showErrorMessage(String message) {
      errorMessage(context, message);
    }

    String _buildSubmissionSummary(ActivityFormState form) {
      String summary = '';
      if (form.answer.isNotEmpty) {
        summary += form.answer.length > 50 ? '${form.answer.substring(0, 50)}...' : form.answer;
      }
      List<String> attachments = [];
      if (form.files.isNotEmpty) {
        attachments.add('${form.files.length} archivo(s)');
      }
      if (form.links.isNotEmpty) {
        attachments.add('${form.links.length} enlace(s)');
      }
      if (attachments.isNotEmpty) {
        summary += summary.isNotEmpty ? ' | ' : '';
        summary += attachments.join(', ');
      }
      return summary;
    }

    DateTime dateNow = DateTime.now();

    return Scaffold(
        floatingActionButton:
            dateNow.isBefore(parseCustomDate(widget.activity.fechaLimite))
                ? FloatingActionButton(
                    onPressed: () {
                      activitiesForm.existsAnswer
                          ? showSendConfirmation()
                          : showModalActivityType(context);
                    },
                    shape: AppTheme.shapeFloatingActionButton(),
                    backgroundColor: Colors.white,
                    child: activitiesForm.existsAnswer
                        ? Icon(
                            Icons.send,
                            color: Colors.grey.withOpacity(0.8),
                          )
                        : SvgPicture.asset(
                            'assets/icons/agregar.svg',
                            color: Colors.black,
                            width: 40,
                            height: 40,
                          ))
                : const SizedBox(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            '',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.nombreActividad,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha vencimiento: ${widget.activity.fechaLimite} ',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.puntaje.toString(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: SingleChildScrollView(
                      child: Text(
                        widget.activity.descripcion,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //TODO: AQUI VAN A ESTAR LAS TAREAS ENTREGADAS
                  lsSubmissions.isNotEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Column(
                            children: [
                              const Text(
                                'Entregables enviados',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  itemCount: lsSubmissions.length,
                                  itemBuilder: (context, index) {
                                    final submission = lsSubmissions[index];

                                    return GestureDetector(
                                      onLongPress: () {
                                        if (submission.status!) {
                                          showModalBottomCancelSubmit(
                                              submission.submissionActivityStudentId);
                                        }
                                      },
                                      child: ElementTile(
                                          iconWidget: SvgPicture.asset('assets/icons/activities20.svg', width: 28, height: 28),
                                          iconColor: Colors.white,
                                          iconSize: 28,
                                          title: "Respuesta",
                                          subtitle: submission.answer != null && submission.answer!.isNotEmpty
                                              ? (submission.answer!.length > 50 ? '${submission.answer!.substring(0, 50)}...' : submission.answer!)
                                              : "Sin texto",
                                          onTapFunction: () {
                                            //TODO: Respuesta content
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Respuesta',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                content: Text(
                                                    submission.answer ?? ""),
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cerrar'))
                                                ],
                                              ),
                                            );
                                          },
                                          trailingString: submission.status!
                                              ? (submission.grade == null
                                                  ? "Enviado"
                                                  : "${submission.grade} /${widget.activity.puntaje}")
                                              : "Pendiente a envió"),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  activitiesForm.existsAnswer
                      ? const Text(
                          'Entregables',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(),
                  Column(
                    children: [
                      activitiesForm.existsAnswer
                          ? GestureDetector(
                              onLongPress: () {
                                showModalBottomDropAnswer(context);
                              },
                              child: SizedBox(
                                height: 180, // Altura mucho mayor con footer
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300, width: 1.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 35,
                                          child: SvgPicture.asset('assets/icons/activities20.svg', width: 50, height: 50),
                                        ),
                                        title: const Text(
                                          'Respuesta',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        subtitle: Text(
                                          activitiesForm.answer.isNotEmpty ? activitiesForm.answer : 'Sin texto',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: IconButton(
                                          onPressed: () {
                                            ref.read(activityFormProvider.notifier).dropAnswer();
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/eliminar4.svg',
                                            width: 40,
                                            height: 40,
                                            colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                                          ),
                                        ),
                                        onTap: () {
                                          showDialogAnswer(context, activitiesForm.answer);
                                        },
                                      ),
                                      Positioned(
                                        bottom: 16,
                                        right: 8,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (activitiesForm.files.isNotEmpty)
                                              Text(
                                                '${activitiesForm.files.length} archivo(s)',
                                                style: const TextStyle(fontSize: 12, color: Colors.blue),
                                              ),
                                            if (activitiesForm.files.isNotEmpty && activitiesForm.links.isNotEmpty)
                                              const SizedBox(width: 8),
                                            if (activitiesForm.links.isNotEmpty)
                                              Text(
                                                '${activitiesForm.links.length} enlace(s)',
                                                style: const TextStyle(fontSize: 12, color: Colors.blue),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

