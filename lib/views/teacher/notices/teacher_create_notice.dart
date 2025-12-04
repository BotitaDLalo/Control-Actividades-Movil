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
      appBar: CustomAppBar( // ⬅️ SIN 'const' aquí
        title: appBarTitle, // Título dinámico
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 25),
        child: CustomRoundedButton(
          text: buttonText,
          // 🚨 LÓGICA DE SUBMIT: Llama a CREAR o ACTUALIZAR
          onPressed: formNotice.isPosting || !formNotice.isValid
              ? null
              : () {
                  if (isEditing) {
                    // Si estamos editando, llamamos a onUpdateSubmit y le pasamos el modelo con ID
                    formNoticeNotifier.onUpdateSubmit(notice);
                  } else {
                    // Si estamos creando, llamamos a onFormSubmit y le pasamos el modelo base
                    formNoticeNotifier.onFormSubmit(notice);
                  }
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
              CustomTextFormField(
                label: 'Título',
                capitalizeFirstLetter: true,
                initialValue: isEditing ? notice.title : null, // ✅ Se mantiene initialValue
                onChanged: formNoticeNotifier.onTitleChanged,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: 'Mensaje',
                capitalizeFirstLetter: true,
                enableLineBreak: true,
                initialValue: isEditing ? notice.description : null, // ✅ Se mantiene initialValue
                onChanged: formNoticeNotifier.onDescriptionChanged,
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

  CustomAppBar({ // Constructor sin const
    super.key,
    required this.title,
    this.leading,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
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
                      child: BackButton(
                        color: Colors.black,
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