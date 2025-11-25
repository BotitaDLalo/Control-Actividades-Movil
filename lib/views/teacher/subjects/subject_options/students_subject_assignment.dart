import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';

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
    }
  });

  return Column( // El widget principal es ahora un Column
    children: [
      Expanded( // Esta sección crecerá y es la única que podrá desplazarse
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- SECCIÓN 1: INPUT Y SUGERENCIA (Altura dinámica) ---
              SizedBox(
                width: 350,
                // height: 150 fue eliminado en el paso anterior
                child: Column(
                  children: [
                    CustomTextFormField(
                      textEditingController: controller,
                      label: 'Agregar alumno',
                      icon: const Icon(Icons.search, color: Colors.grey),
                    ),
                    isNotEmpty
                        ? SizedBox(
                            width: 330,
                            child: Container(
                              color: Colors.grey.shade200,
                              child: ListTile(
                                onTap: () async {
                                  if (formSubjects.isPosting) return;
                                  await ref
                                      .read(formSubjectsProvider.notifier)
                                      .onVerifyEmailSubmit(content);
                                },
                                title: const Text(
                                  'Agregar',
                                  style: TextStyle(fontSize: 16.5),
                                ),
                                subtitle: Text(
                                  content,
                                  style: const TextStyle(fontSize: 16.5),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_add),
                                  iconSize: 30,
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              
              // --- SECCIÓN 2: LISTADO DE ALUMNOS (Contenido scrollable) ---
              // Nota: Mantuve el height: 350. Si quieres que la lista crezca infinitamente, puedes quitarlo.
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
                    Expanded( // Aseguramos que el ListView ocupe el espacio restante
                      child: SizedBox(
                        width: 360,
                        child: ListView.builder(
                          itemCount: lsEmails.length,
                          itemBuilder: (context, index) {
                            final email = lsEmails[index];
                            if (email.isEmailValid) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                // ... contenido de ListTile ...
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                child: ListTile(
                                  leading: IconButton(
                                    icon: const Icon(Icons.person),
                                    iconSize: 30,
                                    onPressed: () {},
                                  ),
                                  title: Text(
                                    email.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16.5),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      ref
                                          .read(studentsSubjectProvider.notifier)
                                          .onDeleteVeryfyEmail(index);
                                    },
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
      ),
      
      // --- SECCIÓN 3: BOTÓN FIJO (Fuera del scroll) ---
      Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20, top: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: CustomRoundedButton(
            text: "Agregar",
            onPressed: () async {
              if (formSubjects.isPosting) return;
              ref
                  .read(formSubjectsProvider.notifier)
                  .onAddStudentsSubjectWithoutGroup(widget.subjectId);
            },
          ),
        ),
      ),
    ],
  );
}
}
