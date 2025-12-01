import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_text_form_field.dart';


class TeacherCreateNotice extends ConsumerStatefulWidget {
  final NoticeModel? notice;          // null al crear, lleno al editar
  final String? externalSubjectName;  // Nombre recibido desde Router

  const TeacherCreateNotice({
    super.key,
    this.notice,
    this.externalSubjectName,
  });

  @override
  ConsumerState<TeacherCreateNotice> createState() =>
      _TeacherCreateNoticeState();
}

class _TeacherCreateNoticeState extends ConsumerState<TeacherCreateNotice> {
  late final bool isEditing;
  late final String subjectName;

  @override
  void initState() {
    super.initState();

    final notice = widget.notice;

    // Estamos editando si el aviso tiene ID
    isEditing = notice?.noticeId != null && notice!.noticeId! > 0;

    // Nombre de la materia SIEMPRE definido
    subjectName = widget.externalSubjectName ??
        notice?.subjectName ??
        "Materia no especificada";

    // Si estamos editando, cargar datos al formulario
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(noticesFormProvider.notifier);

        notifier.onInitializeEditData(
          notice!.noticeId!,
          notice.title,
          notice.description,
        );

        notifier.onTitleChanged(notice.title);
        notifier.onDescriptionChanged(notice.description);
      });
          print("NOTICE AL EDITAR: ${widget.notice}");
          print("EXTERNAL SUBJECT NAME: ${widget.externalSubjectName}");

    }
  }

  @override
  Widget build(BuildContext context) {
    final formNotifier = ref.read(noticesFormProvider.notifier);
    final formState = ref.watch(noticesFormProvider);
    final notice = widget.notice ?? NoticeModel();

    // Escuchar si el formulario terminó correctamente
    ref.listen(noticesFormProvider, (previous, next) {
      if (next.isFormPosted && !next.isPosting) {
        if (context.mounted) {
          context.pop();
        }
      }
    });

    final appBarTitle = isEditing ? "Editar aviso" : "Crear aviso";
    final buttonText = isEditing ? "Guardar cambios" : "Crear";

    return Scaffold(
      appBar: CustomAppBar(title: appBarTitle),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 25,
          left: 25,
          right: 25,
        ),
        child: CustomRoundedButton(
          text: buttonText,
          onPressed: formState.isPosting || !formState.isValid
              ? null
              : () {
                  if (isEditing) {
                    formNotifier.onUpdateSubmit(notice);
                  } else {
                    formNotifier.onFormSubmit(notice);
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
              /// Nombre de la materia — ahora SIEMPRE correcto
              Text(
                subjectName,
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

              /// Campo Título
              CustomTextFormField(
                label: 'Título',
                capitalizeFirstLetter: true,
                initialValue: isEditing ? notice.title : null,
                onChanged: formNotifier.onTitleChanged,
              ),

              const SizedBox(height: 20),

              /// Campo Mensaje
              CustomTextFormField(
                label: 'Mensaje',
                enableLineBreak: true,
                capitalizeFirstLetter: true,
                initialValue: isEditing ? notice.description : null,
                onChanged: formNotifier.onDescriptionChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// AppBar Personalizado
// ----------------------------------------------------

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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

            // Botón de retroceso
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
