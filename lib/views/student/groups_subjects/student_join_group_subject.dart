import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/group_subjects/form_groups_subjects_provider.dart';
import 'package:aprende_mas/providers/group_subjects/groups_subjects_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/button_login.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';

class StudentJoinGroupSubject extends ConsumerWidget {
  const StudentJoinGroupSubject({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formCodeClass = ref.watch(formStudentJoinClassProvider);

    hideSnackBar() {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    ref.listen(
      formStudentJoinClassProvider,
      (previous, next) {
        if (next.isPosting) {
          FocusScope.of(context).unfocus();
          showLoadingScreen(context);
        }
      },
    );

    ref.listen(
      formStudentJoinClassProvider,
      (previous, next) {
        if (!next.isPosting && next.isFormPosted) {
          Navigator.of(context).pop(); // Cerrar loading screen
          // Mostrar mensaje de éxito antes de navegar
          SuccessDialog.show(
            context,
            message: 'Te has unido a la clase correctamente',
            onOkPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        }
      },
    );

    ref.listen(
      groupsSubjectsProvider,
      (previous, next) {
        if (next.errorMessage.isNotEmpty) {
          Navigator.of(context).pop(); // Cerrar loading screen
          hideSnackBar();

          // Mostrar directamente el mensaje del backend
          String errorMessage = next.errorMessage;

          ErrorDialog.show(
            context,
            message: errorMessage,
            onOkPressed: () {
              // Solo cerrar el diálogo, mantener al usuario en la pantalla
              // para que pueda intentar con otro código
            },
          );
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBarHome(
              title: 'Ingresa código de clase',
              showSettings: false,
              titleFontSize: 21,
              leading: IconButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  context.pop();
                },
                icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 30, height: 30, color: Colors.white),
                color: Colors.white,
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  /*
                  const Text(
                    'Ingresa el código de clase',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  */
                  Form(
                      child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        CustomTextFormField(
                          label: 'Código',
                          onChanged: ref
                              .read(formStudentJoinClassProvider.notifier)
                              .onCodeInputChange,
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
            bottomSheet: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.080,
                child: ButtonLogin(
                  text: 'Ingresar',
                  onPressed: () {
                    if (formCodeClass.isPosting) return;
                    ref
                        .read(formStudentJoinClassProvider.notifier)
                        .onFormSubmit();
                  },
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0FA4E0),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  textColor: Colors.white,
                )),
          )
        ],
      ),
    );
  }
}
