import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            padding: const EdgeInsets.only(bottom: 100), // Espacio para el botón fijo
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
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: '  Agregar alumno',
                          prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
                          prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn))),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                        ),
                      ),
 
                      isNotEmpty
                          ? SizedBox(
                              width: 330,
                              child: ElementTile(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/user2.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                ),
                                iconColor: Colors.white,
                                iconSize: 32,
                                title: 'Agregar',
                                subtitle: content,
                                onTapFunction: () async {
                                  if (!formStudentsGroups.isPosting) {
                                    await ref
                                        .read(formStudentsGroupProvider
                                            .notifier)
                                        .onVerifyEmailSubmit(content);
                                  }
                                },
                                trailingWidget: IconButton(
                                  icon: Icon(Icons.person_add, color: Colors.blue),
                                  iconSize: 30,
                                  onPressed: () {},
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
                                return ElementTile(
                                  iconWidget: SvgPicture.asset(
                                    'assets/icons/user2.svg',
                                    width: 32,
                                    height: 32,
                                    colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                  ),
                                  iconColor: Colors.white,
                                  iconSize: 32,
                                  title: email.email,
                                  subtitle: '',
                                  trailingWidget: IconButton(
                                    onPressed: () {
                                      ref
                                          .read(studentsGroupProvider.notifier)
                                          .onDeleteVeryfyEmail(index);
                                    },
                                    icon: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
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
          ),
        ],
      ),
    );
  }
}
