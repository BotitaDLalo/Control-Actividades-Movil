import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late final String _draftKey;
  BuildContext? _safeContext;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _draftKey = 'draft_activity_${widget.activity.activityId}';
    
    // Cargar borrador guardado cuando entras a la vista
    // Usa un delay para asegurar que el build ya pasó
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadSavedDraft();
    });
  }

  /// Cargar borrador guardado de SharedPreferences
  Future<void> _loadSavedDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activityId = widget.activity.activityId;
      
      // Usar la misma clave que se usa para guardar
      final savedData = prefs.getString(_draftKey);
      
      debugPrint('🔍 Buscando borrador con clave: $_draftKey');
      debugPrint('📦 Datos encontrados: ${savedData != null ? "SÍ" : "NO"}');
      
      if (savedData != null) {
        final data = jsonDecode(savedData);
        debugPrint('📄 Contenido guardado: $data');
        
        final formNotifier = ref.read(activityFormProvider.notifier);
        
        // Restaurar la respuesta de texto
        if (data['answer'] != null && data['answer'].isNotEmpty) {
          formNotifier.onAnswerChanged(data['answer']);
          debugPrint('✅ Texto cargado: "${data['answer']}"');
        }
        
        // Restaurar enlaces
        if (data['links'] != null && (data['links'] as List).isNotEmpty) {
          final links = List<String>.from(data['links']);
          formNotifier.onLinksChanged(links);
          debugPrint('✅ Enlaces cargados: ${links.length} enlaces');
        }
        
        // Restaurar archivos
        if (data['files'] != null && (data['files'] as List).isNotEmpty) {
          final filesData = List<Map<String, dynamic>>.from(data['files']);
          final files = filesData.map((fileData) {
            // Recrear PlatformFile desde los datos guardados
            return PlatformFile(
              path: fileData['path'] ?? '',
              name: fileData['name'] ?? 'archivo',
              size: fileData['size'] ?? 0,
            );
          }).toList();
          formNotifier.onFilesChanged(files);
          debugPrint('✅ Archivos cargados: ${files.length} archivos');
        }
        
        // Actualizar existsAnswer después de cargar todo
        await formNotifier.onHasSubmission();
        
        // Forzar rebuild
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {});
      } else {
        debugPrint('⚠️ No se encontró borrador para esta actividad');
      }
    } catch (e) {
      debugPrint('❌ Error cargando borrador: $e');
    }
  }

  /// Guardar borrador en SharedPreferences
  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final form = ref.read(activityFormProvider);
      
      // Convertir archivos a datos serializables
      final filesData = form.files.map((file) => {
        'path': file.path,
        'name': file.name,
        'size': file.size,
      }).toList();
      
      final draftData = {
        'answer': form.answer,
        'links': form.links,
        'files': filesData,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_draftKey, jsonEncode(draftData));
      debugPrint('💾 Borrador guardado: Texto=${form.answer.isNotEmpty}, Enlaces=${form.links.length}, Archivos=${form.files.length}');
    } catch (e) {
      debugPrint('❌ Error guardando borrador: $e');
    }
  }

  /// Eliminar borrador
  Future<void> _deleteDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      debugPrint('🗑️ Borrador eliminado');
    } catch (e) {
      debugPrint('❌ Error eliminando borrador: $e');
    }
  }

  /// Guardar datos antes de salir de la vista
  Future<bool> _saveBeforeExit() async {
    await _saveDraft();
    return true;
  }

  void showDialogAnswer(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => DialogTextField(
        answer: content,
        buttonName: "Modificar",
      ),
    ).then((_) {
      // Guardar el borrador después de cerrar el dialog
      _saveDraft();
    });
  }

  void showModalTextField(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DialogTextField(
        buttonName: 'Agregar',
      ),
    ).then((_) {
      // Guardar el borrador después de cerrar el dialog
      _saveDraft();
    });
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
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _safeContext = context;
    final authConectionType = ref.read(authProvider).authConectionType;
    final activityId = widget.activity.activityId;
    final activitiesForm = ref.watch(activityFormProvider);
    final lsSub = ref.watch(activityProvider).lsSubmissions;
    final lsSubmissions = Submission.activitiesBySubject(lsSub, activityId!);

    void showSendConfirmation() {
      if (_safeContext == null) return;
      
      showDialog(
        context: _safeContext!,
        builder: (dialogContext) => AlertDialog(
          title: const Text(
            'Enviar',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          ),
          content: const Text('¿Quiere realizar el envio?'),
          contentPadding: const EdgeInsets.all(10),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  
                  bool success = false;
                  try {
                    if (authConectionType == AuthConnectionType.online) {
                      success = await ref
                          .read(activityFormProvider.notifier)
                          .onSendSubmission(activityId);
                    } else if (authConectionType == AuthConnectionType.offline) {
                      success = await ref
                          .read(activityFormProvider.notifier)
                          .onSendSubmissionOffline(activityId);
                    }
                    
                    if (mounted) {
                      if (success) {
                        SuccessDialog.show(
                          _safeContext!,
                          message: 'Entrega realizada correctamente',
                        );
                      } else {
                        ErrorDialog.show(
                          _safeContext!,
                          message: 'Error al realizar la entrega',
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ErrorDialog.show(
                        _safeContext!,
                        message: 'Error de conexión',
                      );
                    }
                  }
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

    return WillPopScope(
      onWillPop: _saveBeforeExit,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton:
            dateNow.isBefore(parseCustomDate(widget.activity.fechaLimite))
                ? FloatingActionButton(
                    onPressed: () {
                      activitiesForm.existsAnswer
                          ? showSendConfirmation()
                          : showModalActivityType(context);
                    },
                    shape: AppTheme.shapeFloatingActionButton(),
                    backgroundColor: Colors.blue, // Círculo azul
                    child: activitiesForm.existsAnswer
                        ? SvgPicture.asset(
                            'assets/icons/send1.svg',
                            color: Colors.white, // Icono en blanco
                            width: 28,
                            height: 28,
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
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Respuesta',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (submission.answer != null && submission.answer!.isNotEmpty)
                                                        Text(
                                                          submission.answer!,
                                                          style: const TextStyle(fontSize: 16),
                                                        ),
                                                      if (submission.links != null && submission.links!.isNotEmpty) ...[
                                                        const SizedBox(height: 16),
                                                        const Text(
                                                          'Enlaces:',
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        ...submission.links!.map((link) => Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              final uri = Uri.parse(link);
                                                              if (await canLaunchUrl(uri)) {
                                                                await launchUrl(uri);
                                                              } else {
                                                                if (mounted) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(content: Text('No se pudo abrir el enlace')),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                            child: Text(
                                                              link,
                                                              style: const TextStyle(
                                                                color: Colors.blue,
                                                                fontSize: 14,
                                                                decoration: TextDecoration.underline,
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                      ],
                                                      if (submission.files != null && submission.files!.isNotEmpty) ...[
                                                        const SizedBox(height: 16),
                                                        const Text(
                                                          'Archivos:',
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                        ...submission.files!.map((file) => Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: Text(
                                                            file,
                                                            style: const TextStyle(fontSize: 14),
                                                          ),
                                                        )),
                                                      ],
                                                    ],
                                                  ),
                                                ),
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
                                height: 180,
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
                                            _deleteDraft();
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
        ),
      ),
    );
  }
}
