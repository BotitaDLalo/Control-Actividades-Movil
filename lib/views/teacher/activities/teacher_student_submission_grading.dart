import 'dart:convert';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:flutter/services.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
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
  
  // Datos parseados del JSON
  String respuestaTexto = '';
  List<String> respuestaEnlaces = [];
  List<dynamic> respuestaArchivos = [];
  String respuestaFechaEntrega = '';

  @override
  void initState() {
    super.initState();
    _parseAnswer();
  }

  void _parseAnswer() {
    try {
      final answer = widget.data.answer;
      if (answer == null || answer.isEmpty) return;

      // Intentar parsear como JSON
      final decoded = jsonDecode(answer);
      
      if (decoded is Map<String, dynamic>) {
        respuestaTexto = decoded['texto'] ?? '';
        respuestaFechaEntrega = decoded['fechaEntrega'] ?? '';
        
        // Parsear enlaces
        if (decoded['enlaces'] != null) {
          respuestaEnlaces = List<String>.from(decoded['enlaces']);
        } else if (decoded['Enlaces'] != null) {
          respuestaEnlaces = List<String>.from(decoded['Enlaces']);
        }
        
        // Parsear archivos
        if (decoded['archivos'] != null) {
          respuestaArchivos = decoded['archivos'];
        } else if (decoded['Archivos'] != null) {
          respuestaArchivos = decoded['Archivos'];
        }
      } else {
        // Si no es JSON, mostrar como texto plano
        respuestaTexto = answer;
      }
    } catch (e) {
      // Si falla el parsing, mostrar como texto plano
      respuestaTexto = widget.data.answer;
      debugPrint('Error parseando respuesta: $e');
    }
  }

  @override
  void dispose() {
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final submissionId = data.submissionId;
    final fullName = data.fullName;
    final userName = data.userName;
    final score = data.score;

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
                      fontSize: 16,
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    
                    // Calificación y Fecha de entrega
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.grade == -1 ? 'Sin calificar' : "Calificación: ${activity.grade}/$score",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (respuestaFechaEntrega.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Entregado: ${respuestaFechaEntrega.split('T')[0]} ${respuestaFechaEntrega.split('T')[1].substring(0, 5)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Campo de texto con la respuesta
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(10, 0, 0, 0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: respuestaTexto),
                        maxLines: null,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Sin respuesta',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sección de archivos adjuntos
                    const Text(
                      'Archivos adjuntos:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    respuestaArchivos.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay archivos adjuntos',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : Column(
                            children: respuestaArchivos.map<Widget>((archivo) {
                              String nombreArchivo = archivo['nombre'] ?? archivo['name'] ?? 'Archivo';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                        nombreArchivo,
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    
                    const SizedBox(height: 16),
                    
                    // Sección de enlaces
                    const Text(
                      'Enlaces:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    respuestaEnlaces.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay enlaces',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : Column(
                            children: respuestaEnlaces.map<Widget>((enlace) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                            fontSize: 14,
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        activityFormNotifier.onSubmissionGradeChanged(value);
                      },
                      keyboardType: TextInputType.number,
                      controller: gradeController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Ingresa la calificación',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '/ $score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 80,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: activityForm.isPosting
                ? null
                : () async {
                    final submitedGraded = await ref
                        .read(activityFormProvider.notifier)
                        .onSubmitGrade(submissionId);

                    if (submitedGraded.isValid) {
                      if (submitedGraded.success) {
                        showSuccessMessage('Se asignó la calificación.');
                        activityNotifier.setSubmissionGrade(
                            int.parse(activityForm.newGrade.value));
                      } else {
                        showErrorMessage('Ocurrio un error');
                      }
                      closeKeyboard();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
