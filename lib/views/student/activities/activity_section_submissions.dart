import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_dialog.dart';
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
                        ref.read(activityProvider.notifier).getSubmissions(activityId);
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

    Widget _buildEstatusWidget() {
      final lsSub = ref.watch(activityProvider).lsSubmissions;
      final lsSubmissions = Submission.activitiesBySubject(lsSub, widget.activity.activityId!);
      final fechaLimite = widget.activity.fechaLimite;
      DateTime? fechaLimiteDate;

      try {
        fechaLimiteDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(fechaLimite);
      } catch (e) {
        try {
          fechaLimiteDate = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(fechaLimite);
        } catch (e) {
          fechaLimiteDate = null;
        }
      }

      if (lsSubmissions.isNotEmpty) {
        return const Text(
          'Estatus: Entregado',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      } else if (fechaLimiteDate != null && DateTime.now().isAfter(fechaLimiteDate)) {
        return const Text(
          'Estatus: Retrasado',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        return const Text(
          'Estatus: Pendiente',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    DateTime dateNow = DateTime.now();

    return WillPopScope(
      onWillPop: _saveBeforeExit,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: Builder(
          builder: (context) {
            final bool isGraded = lsSubmissions.any((s) => s.grade != null);
            DateTime? fechaLimiteDate;
            try {
              fechaLimiteDate = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(widget.activity.fechaLimite);
            } catch (e) {
              try {
                fechaLimiteDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(widget.activity.fechaLimite);
              } catch (e) {
                fechaLimiteDate = null;
              }
            }
            final bool isOverdue = fechaLimiteDate != null && DateTime.now().isAfter(fechaLimiteDate);
            final bool canSend = !isGraded && !isOverdue && activitiesForm.existsAnswer;

            if (!canSend && !isGraded && isOverdue) {
              return FloatingActionButton(
                onPressed: () {
                  WarningDialog.show(
                    context,
                    message: 'No puedes enviar: La actividad está vencida',
                  );
                },
                backgroundColor: Colors.grey.shade300,
                shape: AppTheme.shapeFloatingActionButton(),
                child: SvgPicture.asset(
                  'assets/icons/agregar.svg',
                  color: Colors.grey.shade600,
                  width: 40,
                  height: 40,
                ),
              );
            }

            if (isGraded) {
              return FloatingActionButton(
                onPressed: () {
                  WarningDialog.show(
                    context,
                    message: 'No puedes enviar: Tu entrega ya fue calificada',
                  );
                },
                backgroundColor: Colors.grey.shade300,
                shape: AppTheme.shapeFloatingActionButton(),
                child: SvgPicture.asset(
                  'assets/icons/agregar.svg',
                  color: Colors.grey.shade600,
                  width: 40,
                  height: 40,
                ),
              );
            }

            return FloatingActionButton(
              onPressed: () {
                activitiesForm.existsAnswer
                    ? showSendConfirmation()
                    : showModalActivityType(context);
              },
              shape: AppTheme.shapeFloatingActionButton(),
              backgroundColor: Colors.blue,
              child: activitiesForm.existsAnswer
                  ? SvgPicture.asset(
                      'assets/icons/send1.svg',
                      color: Colors.white,
                      width: 28,
                      height: 28,
                    )
                  : SvgPicture.asset(
                      'assets/icons/agregar.svg',
                      color: Colors.white,
                      width: 40,
                      height: 40,
                    ),
            );
          },
        ),
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
                  _buildEstatusWidget(),
                  const SizedBox(height: 8),
                  Text(
                    'Puntuaje Total: ${widget.activity.puntaje}',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  // Mostrar calificación (siempre visible si hay entregas)
                  if (lsSubmissions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Calificación: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lsSubmissions.any((s) => s.grade != null))
                          Text(
                            lsSubmissions.where((s) => s.grade != null).first.grade!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const Text(
                            'sin calificación',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (lsSubmissions.any((s) => s.grade != null))
                          SvgPicture.asset(
                            'assets/icons/palomita2.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                          ),
                      ],
                    ),
                    if (lsSubmissions.any((s) => s.gradedDate != null)) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Fecha que se calificó: ${lsSubmissions.where((s) => s.gradedDate != null).first.gradedDate}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
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
                  //ENTREGABLES ENVIADOS
                  lsSubmissions.isNotEmpty
                      ? SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Entregables enviados',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  itemCount: lsSubmissions.length,
                                  itemBuilder: (context, index) {
                                    final submission = lsSubmissions[index];

                                    return ElementTile(
                                      iconWidget: SvgPicture.asset('assets/icons/activities20.svg', width: 50, height: 50),
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
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Mostrar calificación si existe
                                                  if (submission.grade != null) ...[
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Calificación: ',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          submission.grade!,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        SvgPicture.asset(
                                                          'assets/icons/palomita2.svg',
                                                          width: 16,
                                                          height: 16,
                                                          colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
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
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/icons/link.svg',
                                                            width: 40,
                                                            height: 40,
                                                            colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
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
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                  if (submission.files != null && submission.files!.isNotEmpty) ...[
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      'Archivos:',
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    ...submission.files!.map((fileUrl) {
                                                      // Procesar la URL igual que en la vista del docente
                                                      String url = fileUrl;
                                                      String nombreMostrar = fileUrl.split('/').last;
                                                      
                                                      // Si la URL no empieza con http, agregar la URL base
                                                      if (!url.startsWith('http')) {
                                                        url = 'http://192.168.0.9:5000$url';
                                                      }
                                                      
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            final uri = Uri.parse(url);
                                                            if (await canLaunchUrl(uri)) {
                                                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                            } else {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(content: Text('No se pudo abrir el archivo')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/icons/documento.svg',
                                                                width: 40,
                                                                height: 40,
                                                                colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                                              ),
                                                              const SizedBox(width: 12),
                                                              Expanded(
                                                                child: Text(
                                                                  nombreMostrar,
                                                                  style: const TextStyle(
                                                                    color: Colors.blue,
                                                                    fontSize: 14,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
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
                                       trailingWidget: submission.status!
                                           ? IconButton(
                                               onPressed: () async {
                                                 if (submission.grade != null && submission.grade!.isNotEmpty) {
                                                   WarningDialog.show(
                                                     context,
                                                     message: 'No puedes cancelar esta entrega pues ya esta calificada',
                                                   );
                                                   return;
                                                 }
                                                 
                                                 if (authConectionType == AuthConnectionType.online) {
                                                   WarningConfirmationDialog.show(
                                                     context,
                                                     message: '¿Estás seguro de que deseas cancelar este entregable?',
                                                     onConfirmPressed: () async {
                                                       bool success = await ref
                                                           .read(activityProvider.notifier)
                                                           .cancelSubmission(
                                                               submission.submissionActivityStudentId,
                                                               widget.activity.activityId!);
                                                       
                                                       if (mounted) {
                                                         if (success) {
                                                           SuccessDialog.show(
                                                             context,
                                                             message: 'Entregable cancelado correctamente',
                                                           );
                                                         } else {
                                                           ErrorDialog.show(
                                                             context,
                                                             message: 'Error al cancelar el entregable',
                                                           );
                                                         }
                                                       }
                                                     },
                                                   );
                                                 } else if (authConectionType == AuthConnectionType.offline) {
                                                   ErrorDialog.show(
                                                     context,
                                                     message: 'No disponible en modo offline',
                                                   );
                                                 }
                                               },
                                               icon: SvgPicture.asset(
                                                 'assets/icons/eliminar4.svg',
                                                 width: 40,
                                                 height: 40,
                                                 colorFilter: ColorFilter.mode(
                                                   submission.grade != null && submission.grade!.isNotEmpty
                                                       ? Colors.grey.shade300
                                                       : Colors.red,
                                                   BlendMode.srcIn,
                                                 ),
                                               ),
                                             )
                                           : null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 40), // Espacio amplio entre secciones
                  activitiesForm.existsAnswer
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Borrador de entregable',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Si necesitas actualizar tu entrega vuelve a enviar el borrador. Nota: Si esta calificada la entrega entonces no se podra reenviar',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
