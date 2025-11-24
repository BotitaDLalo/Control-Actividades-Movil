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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [ 
            CustomTextFormField(
              icon: SvgPicture.asset(
                'assets/icons/email.svg',
                width: 10,
                height: 10,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: '  Correo',
              textEditingController: loginFormNotifier.emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: loginFormNotifier.onEmailChanged,
              errorMessage:
                  loginForm.isFormPosted ? loginForm.email.errorMessage : null,
            ),
            const SizedBox(height: 5),
            CustomTextFormField(
              icon: SvgPicture.asset(
                'assets/icons/password1.svg',
                width: 10,
                height: 10,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: '  Contraseña',
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
              height: 20,
            ),

            SizedBox(
                width: double.infinity,
                //width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 20, 158, 218),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 18, // Aumenta el tamaño de letra a 20
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
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
              height: 18,
            ),
            SizedBox(
                width: double.infinity,
                //width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.080,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 8, 108, 158),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    side: BorderSide(color: const Color.fromARGB(255, 14, 155, 226)),
                  ),
                  onPressed: () {
                    loginFormNotifier.resetStateForm();
                    context.push('/verify-email-signin-screen');
                  },
                  child: const Text('Registrarse'),
                )),

            //TODO: BOTON DE REGISTRARSE
            const SizedBox(height: 35),

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
              height: 10,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 7, 142, 160),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
              /*
              icon: SvgPicture.asset(
                'assets/icons/icon_google.svg',
                width: 25,
                height: 25,
              ),
              */
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
