import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/environment/environment.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:flutter/services.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherStudentSubmissionGrading extends ConsumerStatefulWidget {
  final TeacherStudentSubmissionGradingModel data;
  const TeacherStudentSubmissionGrading({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeacherStudentSubmissionGradingState();
}

class _TeacherStudentSubmissionGradingState
    extends ConsumerState<TeacherStudentSubmissionGrading> {
  final gradeController = TextEditingController();

  @override
  void dispose() {
    gradeController.dispose();
    super.dispose();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      // El formato del backend es: 2026-02-04T17:42:56.17
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr; // Si hay error, retornar el original
    }
  }

  DateTime _parseDateTime(String str) {
    try {
      return DateTime.parse(str);
    } catch (e) {
      try {
        final parts = str.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        return DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );
      } catch (e2) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final submissionId = data.submissionId;
    final fullName = data.fullName;
    final userName = data.userName;
    final score = data.score;
    final answer = data.answer;
    final links = data.links;
    final files = data.files;
    final submissionDate = data.submissionDate;

    final activity = ref.watch(activityProvider);
    final activityNotifier = ref.read(activityProvider.notifier);

    final activityForm = ref.watch(activityFormProvider);
    final activityFormNotifier = ref.read(activityFormProvider.notifier);

    hideSnackBar() {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    showSuccessMessage(String message) {
      hideSnackBar();
      SuccessDialog.show(context, message: message);
    }

    showErrorMessage(String message) {
      hideSnackBar();
      ErrorDialog.show(context, message: message);
    }

    closeKeyboard() {
      gradeController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        forceMaterialTransparency: true,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de información del alumno
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 22,
                    child: SvgPicture.asset(
                      'assets/icons/user2.svg',
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                          Colors.black, BlendMode.srcIn),
                    ),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Card de respuesta del alumno
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Respuesta',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    
                    // Fecha de envío
                    Text(
                      'Enviado: ${_formatDateTime(data.submissionDate)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    if (data.deadline.isNotEmpty && data.submissionDate.isNotEmpty) ...[
                      if (_parseDateTime(data.submissionDate).isAfter(_parseDateTime(data.deadline))) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Entrega tardía',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    
                    // Calificación y Fecha de entrega
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.grade == -1 ? 'Sin calificar' : "Calificación: ${activity.grade}/$score",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    
                    // Campo de texto con la respuesta
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(10, 0, 0, 0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: answer),
                        maxLines: null,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Sin respuesta',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sección de archivos adjuntos
                    const Text(
                      'Archivos adjuntos:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    files.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay archivos adjuntos',
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          )
                        : Column(
                            children: files.map<Widget>((archivo) {
                              String url = archivo.ruta.isNotEmpty ? archivo.ruta : '';
                              String nombreMostrar = archivo.nombre.isNotEmpty ? archivo.nombre : '';
                              
                              if (url.isEmpty && nombreMostrar.isNotEmpty && nombreMostrar.startsWith('/')) {
                                url = nombreMostrar;
                              }
                              
                               if (url.isNotEmpty) {
                                 String baseUrl = Environment.apiUrl.replaceAll(RegExp(r'/?api/?$'), '');
                                 if (!url.startsWith('http')) {
                                   url = '$baseUrl$url';
                                 }
                                if (nombreMostrar.isEmpty) {
                                  nombreMostrar = url.split('/').last;
                                }
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (url.isNotEmpty) {
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
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/documento.svg',
                                        width: 40,
                                        height: 40,
                                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          nombreMostrar,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    
                    const SizedBox(height: 24),
                    
                    // Sección de enlaces
                    const Text(
                      'Enlaces:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    links.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay enlaces',
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          )
                        : Column(
                            children: links.map<Widget>((enlace) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/link.svg',
                                      width: 40,
                                      height: 40,
                                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final uri = Uri.parse(
                                            enlace.startsWith('http') ? enlace : 'https://$enlace'
                                          );
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        child: Text(
                                          enlace,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
               
              const SizedBox(height: 24),
               
              // Sección de nueva calificación
              const Text(
                'Asignar Calificación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
              ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  final gradeValue = double.tryParse(gradeController.text) ?? 0;
                  final isGradeInvalid = gradeValue > score;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                activityFormNotifier.onSubmissionGradeChanged(value);
                                setState(() {});
                              },
                              keyboardType: TextInputType.number,
                              controller: gradeController,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              decoration: InputDecoration(
                                labelText: 'Ingresa la calificación',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isGradeInvalid ? Colors.red : Colors.blue, width: 2.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isGradeInvalid ? Colors.red : Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '/ $score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (isGradeInvalid) ...[
                        const SizedBox(height: 8),
                        Text(
                          'La calificación no puede ser mayor a $score',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (activity.grade != null && activity.grade > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: activityForm.isPosting
                        ? null
                        : () {
                            WarningConfirmationDialog.show(
                              context,
                              message: '¿Estás seguro de quitar la calificación a este alumno?',
                              onConfirmPressed: () async {
                                bool success = await activityNotifier.removeGrade(submissionId);
                                if (mounted) {
                                  if (success) {
                                    SuccessDialog.show(
                                      context,
                                      message: 'Calificación quitada correctamente',
                                    );
                                    gradeController.clear();
                                  } else {
                                    ErrorDialog.show(
                                      context,
                                      message: 'Error al quitar calificación',
                                    );
                                  }
                                }
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Quitar Calificación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 80,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: SizedBox(
          width: double.infinity,
          child: Builder(
            builder: (context) {
              final gradeValue = double.tryParse(gradeController.text) ?? 0;
              final isGradeInvalid = gradeValue > score;
              final canSubmit = !activityForm.isPosting && !isGradeInvalid && gradeController.text.isNotEmpty;
              
              return ElevatedButton(
                onPressed: canSubmit
                    ? () async {
                        final submitedGraded = await ref
                            .read(activityFormProvider.notifier)
                            .onSubmitGrade(submissionId);

                        if (submitedGraded.isValid) {
                          if (submitedGraded.success) {
                            showSuccessMessage('Se asignó la calificación.');
                            activityNotifier.setSubmissionGrade(
                                double.parse(activityForm.newGrade.value));
                          } else {
                            showErrorMessage('Ocurrio un error');
                          }
                          closeKeyboard();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGradeInvalid ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Asignar Calificación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
