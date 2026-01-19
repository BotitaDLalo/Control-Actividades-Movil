import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
// CAMBIO: Import agregado para mostrar mensajes de error con snackbar
import 'package:aprende_mas/views/widgets/alerts/error_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Asegurar importación de Material/Widget
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';

class TeacherCreateNotice extends ConsumerStatefulWidget {
  final NoticeModel notice;
  const TeacherCreateNotice({super.key, required this.notice});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeacherCreateNoticeState();
}

class _TeacherCreateNoticeState extends ConsumerState<TeacherCreateNotice> {
  // 1. Determinar el modo: 'true' si estamos editando un aviso existente.
  late final bool isEditing;

  @override
  void initState() {
    super.initState();
    final NoticeModel notice = widget.notice;
    
    // Un aviso es para edición si NoticeId es diferente de null y mayor que 0.
    isEditing = notice.noticeId != null && notice.noticeId! > 0;
    
    // Si estamos en modo edición, inicializamos el estado del form provider 
    // con los datos del aviso actual.
    if (isEditing) {
      // Usamos addPostFrameCallback para asegurar que el contexto de Riverpod esté listo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Inicializa el provider con los valores del aviso para edición
        ref.read(noticesFormProvider.notifier).onInitializeEditData(
          notice.noticeId!,
          notice.title, 
          notice.description,
        );
        // Opcional: Asegurar que el provider sepa los valores iniciales.
        ref.read(noticesFormProvider.notifier).onTitleChanged(notice.title);
        ref.read(noticesFormProvider.notifier).onDescriptionChanged(notice.description);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formNoticeNotifier = ref.read(noticesFormProvider.notifier);
    final formNotice = ref.watch(noticesFormProvider);
    NoticeModel notice = widget.notice;
    final subjectColor = getSubjectColor(notice.subjectId ?? 0);
    final isGroup = notice.groupId != null && notice.groupId! > 0;
    final displayColor = isGroup ? Colors.blue : subjectColor;

    ref.listen(
      noticesFormProvider,
      (previous, next) {
        if (next.isFormPosted && !next.isPosting) {
          // CAMBIO: Solo hacer pop cuando la creación fue exitosa
          context.pop();
        }
        // CAMBIO: Mostrar mensaje de error si la creación falló
        if (next.errorMessage.isNotEmpty && !next.isPosting) {
          errorMessage(context, next.errorMessage);
        }
      },
    );

    // 🆕 Títulos y textos condicionales
    final String appBarTitle = isEditing ? 'Editar aviso' : 'Crear aviso';
    final String buttonText = isEditing ? 'Guardar Cambios' : 'Crear';

    // 🛑 La clase CustomAppBar estaba aquí, causando el error. Ahora está fuera.

    return Scaffold( // ⬅️ SIN 'const' aquí
      resizeToAvoidBottomInset: false, // Evita que el contenido suba con el teclado
      appBar: CustomAppBar( // ⬅️ SIN 'const' aquí
        title: appBarTitle, // Título dinámico
        displayColor: displayColor,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 25),
        child: CustomRoundedButton(
          text: buttonText,
          backgroundColor: displayColor,
          // 🚨 LÓGICA DE SUBMIT: Llama a CREAR o ACTUALIZAR
          onPressed: formNotice.isPosting || !formNotice.isValid
              ? null
              : () {
                  // Mostrar diálogo de confirmación antes de crear/editar
                  WarningConfirmationDialog.show(
                    context,
                    message: isEditing
                      ? '¿Está seguro de que desea actualizar este aviso?'
                      : '¿Está seguro de que desea crear este aviso?',
                    onConfirmPressed: () async {
                      try {
                        if (isEditing) {
                          // Si estamos editando, llamamos a onUpdateSubmit y le pasamos el modelo con ID
                          final success = await formNoticeNotifier.onUpdateSubmit(notice);
                          if (success) {
                            // Mostrar mensaje de éxito
                            SuccessDialog.show(
                              context,
                              message: 'Aviso actualizado exitosamente',
                              onOkPressed: () {
                                context.pop();
                              },
                            );
                          } else {
                            // Mostrar mensaje de error
                            ErrorDialog.show(
                              context,
                              message: 'No se pudo actualizar el aviso. Por favor, intente de nuevo.',
                            );
                          }
                        } else {
                          // Si estamos creando, llamamos a onFormSubmit y le pasamos el modelo base
                          final success = await formNoticeNotifier.onFormSubmit(notice);
                          if (success) {
                            // Mostrar mensaje de éxito
                            SuccessDialog.show(
                              context,
                              message: 'Aviso creado exitosamente',
                              onOkPressed: () {
                                context.pop();
                              },
                            );
                          } else {
                            // Mostrar mensaje de error
                            ErrorDialog.show(
                              context,
                              message: 'No se pudo crear el aviso. Por favor, intente de nuevo.',
                            );
                          }
                        }
                      } catch (e) {
                        // Captura cualquier error en la creación/actualización del aviso
                        print("Error al crear/actualizar el aviso: $e");
                        // Mostrar mensaje de error
                        ErrorDialog.show(
                          context,
                          message: 'Error al crear/actualizar el aviso: $e',
                        );
                      }
                    },
                    onCancelPressed: () {
                      // No hacer nada, solo cerrar el diálogo
                    },
                  );
                },
        ),
      ),

      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
                widget.notice.subjectName ?? 'Materia General',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Redacta un nuevo aviso para tu materia.\n'
                'Puedes incluir texto, enlaces o archivos adjuntos para tus estudiantes.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              // 3. Campos del formulario (Usando initialValue como solicitaste)
              TextFormField(
                initialValue: isEditing ? notice.title : null,
                onChanged: formNoticeNotifier.onTitleChanged,
                decoration: InputDecoration(
                  labelText: 'Título',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: displayColor, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: isEditing ? notice.description : null,
                onChanged: formNoticeNotifier.onDescriptionChanged,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Mensaje',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: displayColor, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ✅ DEFINICIÓN DE CustomAppBar (DEBE ESTAR FUERA DEL MÉTODO build)
// ----------------------------------------------------
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Color displayColor;

  CustomAppBar({ // Constructor sin const
    super.key,
    required this.title,
    this.leading,
    required this.displayColor,
  });

  // 🔴 ¡IMPLEMENTACIÓN CORRECTA DEL BUILD DE CONSUMERWIDGET!
  // Debe aceptar BuildContext y WidgetRef.
  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25 / 2.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: displayColor,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leading ??
                    Transform.translate(
                  offset: const Offset(-14, 0),
                  child: IconButton(
                    icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: displayColor),
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 80);
}
