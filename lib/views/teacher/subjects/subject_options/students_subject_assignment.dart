import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

final contentProvider = StateProvider<String>((ref) => '');
final addStudentMessageProvider = StateProvider<bool>((ref) => false);

class StudentsSubjectAssignment extends ConsumerStatefulWidget {
  final int? groupId;
  final int subjectId;
  const StudentsSubjectAssignment(
      {super.key, this.groupId, required this.subjectId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentsSubjectAssignmentState();
}

class _StudentsSubjectAssignmentState
    extends ConsumerState<StudentsSubjectAssignment> {
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        ref.read(contentProvider.notifier).state = controller.text;
        ref.read(addStudentMessageProvider.notifier).state = true;
      } else {
        ref.read(addStudentMessageProvider.notifier).state = false;
      }
    });
  }

  @override
 Widget build(BuildContext context) {
   final isNotEmpty = ref.watch(addStudentMessageProvider);
   final content = ref.watch(contentProvider);
   final formSubjects = ref.watch(formSubjectsProvider);
   final lsEmails = ref.watch(studentsSubjectProvider).lsEmails;
   final canSubmit = lsEmails.isNotEmpty && !formSubjects.isPosting;
   final subjectColor = getSubjectColor(widget.subjectId);
   final isGroup = widget.groupId != null;
   final displayColor = isGroup ? Colors.blue : subjectColor;

  void clear() {
    controller.clear();
    ref.read(addStudentMessageProvider.notifier).state = false;
    FocusScope.of(context).unfocus();
  }

  // Listeners permanecen igual
  ref.listen(
    formSubjectsProvider,
    (previous, next) {
      final isValid = next.verifyEmail?.isEmailValid ?? false;
      if (isValid) {
        clear();
      }
    },
  );

  ref.listen(formSubjectsProvider, (previous, next) {
    final isFormPosted = next.isFormPosted;
    if (isFormPosted) {
      ref.read(studentsSubjectProvider.notifier).clearLsEmails();
      // Mostrar diálogo de éxito
      SuccessDialog.show(
        context,
        message: 'Alumno agregado correctamente',
      );
    }
  });

  return Scaffold(
    resizeToAvoidBottomInset: false, // Evita que el contenido suba con el teclado
    body: Stack(
      children: [
        // Contenido scrollable
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20), // Espacio para el botón fijo y márgenes laterales
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- SECCIÓN 1: INPUT Y SUGERENCIA (Altura dinámica) ---
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: '  Agregar alumno',
                        prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
                        prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn))),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: subjectColor, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                    isNotEmpty
                        ? SizedBox(
                            width: 300,
                            child: ElementTile(
                              iconWidget: SvgPicture.asset(
                                'assets/icons/user2.svg',
                                width: 32,
                                height: 32,
                                colorFilter: ColorFilter.mode(displayColor, BlendMode.srcIn),
                              ),
                              iconColor: Colors.white,
                              iconSize: 32,
                              title: 'Agregar',
                              subtitle: content,
                              onTapFunction: () async {
                                if (formSubjects.isPosting) return;
                                await ref
                                    .read(formSubjectsProvider.notifier)
                                    .onVerifyEmailSubmit(content);
                              },
                              trailingWidget: IconButton(
                                icon: Icon(Icons.person_add, color: displayColor),
                                iconSize: 30,
                                onPressed: () {},
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),

              // --- SECCIÓN 2: LISTADO DE ALUMNOS (Contenido scrollable) ---
              SizedBox(
                height: 350,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                      child: Text(
                        'Agregar alumnos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 320,
                        child: ListView.builder(
                          itemCount: lsEmails.length,
                          itemBuilder: (context, index) {
                            final email = lsEmails[index];
                            if (email.isEmailValid) {
                              return ElementTile(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/user2.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(displayColor, BlendMode.srcIn),
                                ),
                                iconColor: Colors.white,
                                iconSize: 32,
                                title: email.email,
                                subtitle: '',
                                trailingWidget: IconButton(
                                  onPressed: () {
                                    ref
                                        .read(studentsSubjectProvider.notifier)
                                        .onDeleteVeryfyEmail(index);
                                  },
                                  icon: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: displayColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/eliminar4.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Botón fijo en la parte inferior
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 150,
              child: CustomRoundedButton(
                text: "Agregar",
                backgroundColor: displayColor,
                onPressed: canSubmit
                    ? () async {
                        print('--- INICIANDO ENVÍO DE ${lsEmails.length} ALUMNOS ---');
                        ref
                            .read(formSubjectsProvider.notifier)
                            .onAddStudentsSubjectWithoutGroup(widget.subjectId);
                      }
                    : null,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
