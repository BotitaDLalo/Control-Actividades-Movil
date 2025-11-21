import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/form_email_provider.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/alerts/custom_alert_dialog.dart';
import 'package:aprende_mas/views/widgets/buttons/button_login.dart';
import 'package:aprende_mas/config/utils/utils.dart';

class VerifyEmailSigninForm extends ConsumerWidget {
  const VerifyEmailSigninForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = KeyValueStorageServiceImpl();
    final formEmail = ref.watch(formEmailProvider);
    final formEmailNotifier = ref.read(formEmailProvider.notifier);

    showErrorAlertDialog(String errorMessage, String errorComment) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            message: errorMessage,
            comment: errorComment,
            buttonCancelName: 'Cancelar',
            onPressedCancel: () => Navigator.of(context).pop(),
            buttonContinueName: 'Iniciar Sesión',
            onPressedContinue: () => context.go('/login-user'),
          );
        },
      );
    }

    void closeLoadingScreen() {
      Navigator.of(context).pop();
    }

    void saveEmailUser() async {
      String email = formEmail.email.value;
      await storageService.saveEmail(email);
    }

    ref.listen(
      formEmailProvider,
      (previous, next) {
        if (next.isFormPosted && !next.isPosting) {
          saveEmailUser();
          context.push('/signin-user');
        }
      },
    );

    ref.listen(
      authProvider,
      (previous, next) {
        if (next.errorMessage.isNotEmpty &&
            next.errorComment.isNotEmpty &&
            next.errorHandlingStyle == ErrorHandlingStyle.dialog) {
          showErrorAlertDialog(next.errorMessage, next.errorComment);
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
            '¿Cual es tu correo?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          */
          const SizedBox(height: 20),
          CustomTextFormField(
            icon: SvgPicture.asset(
                'assets/icons/email.svg',
                width: 10,
                height: 10,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
            label: '  Correo',
            keyboardType: TextInputType.emailAddress,
            onChanged: formEmailNotifier.onEmailChanged,
            // errorMessage:
            //     siginForm.isFormPosted ? siginForm.email.errorMessage : null,
          ),
          const SizedBox(
            height: 65,
          ),
          
          // Nuevo boton personalizado
          SizedBox(
                //width: double.infinity,
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.080,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 158, 223),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: const Color.fromARGB(255, 14, 155, 226)),
                  ),
                  onPressed: () async {
                // if (formEmail.isPosting) {
                //   return;
                // }
                // formEmailNotifier.onVerifyEmailSigninSubmit();

                if (formEmail.isPosting) return;

                if (!formEmail.email.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("El correo no es válido"),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return; // Detener la ejecución si el formulario no es válido
                }

                try {
                  await formEmailNotifier.onVerifyEmailSigninSubmit();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
                  child: const Text('Verificar'),
                )),


        ],
      ),
    ));
  }
}
