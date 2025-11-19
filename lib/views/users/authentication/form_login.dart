import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';


class FormLogin extends ConsumerStatefulWidget {
  const FormLogin({super.key});

  @override
  FormLoginState createState() => FormLoginState();
}

class FormLoginState extends ConsumerState<FormLogin> {
  @override
  void initState() {
    super.initState();
    ref.read(firebasecmProvider.notifier).onRequestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(loginFormProvider);
    final loginFormNotifier = ref.read(loginFormProvider.notifier);
    final fcm = ref.watch(firebasecmProvider);

    hideSnackBar() {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    ref.listen(
      loginFormProvider,
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
            CustomTextFormField(
              icon: const Icon(
                Icons.alternate_email,
                size: 25,
              ),
              label: 'Correo',
              textEditingController: loginFormNotifier.emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: loginFormNotifier.onEmailChanged,
              errorMessage:
                  loginForm.isFormPosted ? loginForm.email.errorMessage : null,
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: const Icon(
                Icons.password_rounded,
                size: 25,
              ),
              label: 'Contraseña',
              textEditingController: loginFormNotifier.passwordController,
              obscureText: true,
              onChanged: loginFormNotifier.onPasswordChanged,
              errorMessage: loginForm.isFormPosted
                  ? loginForm.password.errorMessage
                  : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/forgot-password');
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.060,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 15, 88, 147),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (loginForm.isPosting) {
                      return;
                    }
                    if (fcm.status == AuthorizationStatus.authorized) {
                      loginFormNotifier.onFormSubmit();
                      if (loginForm.isValid) {
                        hideSnackBar();
                        // showLoadingScreen(context);
                      }
                    } else {
                      ref
                          .read(firebasecmProvider.notifier)
                          .onRequestPermissions();
                    }
                  },
                  child: const Text('Iniciar Sesión'),
                )),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.060,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 56, 87),
                    foregroundColor: const Color.fromARGB(255, 234, 235, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.blue[800]!),
                  ),
                  onPressed: () {
                    loginFormNotifier.resetStateForm();
                    context.push('/verify-email-signin-screen');
                  },
                  child: const Text('Registrarse'),
                )),

            //TODO: BOTON DE REGISTRARSE
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  )),
                  Text(
                    'O inicia sesión con',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Flexible(
                      child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  )),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 108, 234, 200),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
              icon: const FaIcon(
                FontAwesomeIcons.google,
                size: 25,
              ),
              onPressed: () {
                loginFormNotifier.onGoogleSubmit();
              },
              label: const Text(
                "Google",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
