import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'package:aprende_mas/providers/authentication/signin_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/button_login.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_dropdown.dart';

class FormSingin extends ConsumerWidget {
  const FormSingin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cn = CatalogNames();
    final List<String> users = [cn.getRoleStudentName, cn.getRoleTeacherName];
    final signinForm = ref.watch(signinFormProvider);
    final signinFormNotifier = ref.read(signinFormProvider.notifier);

    // hideSnackBar() {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    // }

    // ref.listen(
    //   authProvider,
    //   (previous, next) {
    //     if (next.errorMessage.isNotEmpty) {
    //       if (next.errorHandlingStyle == ErrorHandlingStyle.snackBar) {
    //         hideSnackBar();
    //         errorMessage(context, next.errorMessage);
    //       }
    //     }
    //   },
    // );

    void goToConfirmationCodeScreen() {
      Navigator.of(context).pop();
      context.push('/confirmation-code-screen');
    }

    closeLoadingScreen() {
      Navigator.of(context).pop();
    }

    ref.listen(
      signinFormProvider,
      (previous, next) {
        if (next.isFormPosted && !next.isPosting) {
          goToConfirmationCodeScreen();
        }
      },
    );

    ref.listen(
      signinFormProvider,
      (previous, next) {
        if (next.isFormNotPosted && !next.isPosting) {
          closeLoadingScreen();
        }
      },
    );

    ref.listen(
      signinFormProvider,
      (previous, next) {
        if (next.isPosting) {
          showLoadingScreen(context);
        }
      },
    );

    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /*
            const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            */
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: SvgPicture.asset(
                'assets/icons/user2.svg',
                width: 20,
                height: 20,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: "  Nombres",
              onChanged: signinFormNotifier.onNameChanged,
              errorMessage:
                  signinForm.isFormPosted ? signinForm.name.errorMessage : null,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    icon: SvgPicture.asset(
                      'assets/icons/user2.svg',
                      width: 20,
                      height: 20,
                      color: const Color.fromARGB(255, 12, 129, 231),
                    ),
                    label: "Apellido Paterno",
                    onChanged: signinFormNotifier.onLastNameChanged,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    icon: SvgPicture.asset(
                      'assets/icons/user2.svg',
                      width: 20,
                      height: 20,
                      color: const Color.fromARGB(255, 12, 129, 231),
                    ),
                    label: "Apellido Materno",
                    onChanged: signinFormNotifier.onSecondLastNameChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: SvgPicture.asset(
                'assets/icons/password1.svg',
                width: 10,
                height: 10,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: '  Contraseña',
              obscureText: true,
              onChanged: signinFormNotifier.onPasswordChanged,
              errorMessage: signinForm.isFormPosted
                  ? signinForm.password.errorMessage
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomDropdown(
              icon: SvgPicture.asset(
                'assets/icons/usercheck1.svg',
                width: 20,
                height: 20,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: '  Elige tu rol',
              items: users,
              onChanged: (p0) {
                signinFormNotifier.onRoleChanged(p0);
              },
            ),
            // const RoleDropdownSigin(),
            const SizedBox(
              height: 65,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.080,
              child: ButtonLogin(
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 20, 158, 218),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  textColor: Colors.white,
                  text: "Enviar",
                onPressed: () {
                  if (signinForm.isPosting) {
                    return;
                  }
                  signinFormNotifier.onFormSigninSubmit();
                },
                //buttonStyle: AppTheme.buttonPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
