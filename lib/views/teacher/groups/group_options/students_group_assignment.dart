import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';

final addStudentGroupMessageProvider = StateProvider<bool>((ref) => false);
final contentGroupProvider = StateProvider<String>((ref) => '');

class StudentsGroupAssigment extends ConsumerStatefulWidget {
  final int id;
  const StudentsGroupAssigment({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentsGroupState();
}

class _StudentsGroupState extends ConsumerState<StudentsGroupAssigment> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        ref.read(contentGroupProvider.notifier).state = controller.text;
        ref.read(addStudentGroupMessageProvider.notifier).state = true;
      } else {
        ref.read(addStudentGroupMessageProvider.notifier).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNotEmpty = ref.watch(addStudentGroupMessageProvider);
    final content = ref.watch(contentGroupProvider);

    final formStudentsGroups = ref.watch(formStudentsGroupProvider);
    final lsEmails = ref.watch(studentsGroupProvider).lsEmails;

    final canSubmit = lsEmails.isNotEmpty && !formStudentsGroups.isPosting;

    void clear() {
      controller.clear();
      ref.read(addStudentGroupMessageProvider.notifier).state = false;
      FocusScope.of(context).unfocus();
    }

    ref.listen(
      formStudentsGroupProvider,
      (previous, next) {
        if (next.verifyEmail?.isEmailValid ?? false) {
          clear();
        }
      },
    );

    ref.listen(formStudentsGroupProvider, (previous, next) {
      if (next.isFormPosted) {
        ref.read(studentsGroupProvider.notifier).clearLsEmails();
      }
    });

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ======================
                //     INPUT + SUGERENCIA
                // ======================
                SizedBox(
                  width: 350,
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
                                    if (!formStudentsGroups.isPosting) {
                                      await ref
                                          .read(formStudentsGroupProvider
                                              .notifier)
                                          .onVerifyEmailSubmit(content);
                                    }
                                  },
                                  title: const Text(
                                    'Agregar',
                                    style: TextStyle(fontSize: 16.5),
                                  ),
                                  subtitle: Text(
                                    content,
                                    style: const TextStyle(fontSize: 16.5),
                                  ),
                                  trailing: const Icon(Icons.person_add, size: 30),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),

                // =========================
                //        LISTA DE EMAILS
                // =========================
                SizedBox(
                  height: 350,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Text(
                          'Agregar alumnos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),

                      Expanded(
                        child: SizedBox(
                          width: 360,
                          child: ListView.builder(
                            itemCount: lsEmails.length,
                            itemBuilder: (context, index) {
                              final email = lsEmails[index];
                              if (email.isEmailValid) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.person, size: 30),
                                    title: Text(
                                      email.email,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16.5),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        ref
                                            .read(studentsGroupProvider.notifier)
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

        // =========================
        //       BOTÓN FIJO
        // =========================
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20, top: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomRoundedButton(
              text: "Agregar",
              onPressed: canSubmit
                  ? () async {
                      print('--- ENVIANDO ${lsEmails.length} ALUMNOS A GRUPO ---');
                      await ref
                          .read(formStudentsGroupProvider.notifier)
                          .onAddStudentsGroup(widget.id);
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
