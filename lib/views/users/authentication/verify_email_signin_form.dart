import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/authentication/auth_errors.dart';
import 'package:aprende_mas/providers/authentication/form_email_provider.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/alerts/custom_alert_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
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

    // Removido: Este listener no debería estar en el form de verificación de email

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
                width: 40,
                height: 40,
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
                  ErrorDialog.show(
                    context,
                    message: "El formato del correo electrónico no es válido",
                  );
                  return; // Detener la ejecución si el formulario no es válido
                }

                try {
                  debugPrint('🚀 Iniciando verificación de email: ${formEmailNotifier.state.email.value}');
                  await formEmailNotifier.onVerifyEmailSigninSubmit();
                  debugPrint('✅ Verificación exitosa - navegando a registro');
                } on InvalidEmailSignin catch (e) {
                  debugPrint('❌ InvalidEmailSignin capturado: ${e.errorMessage}');
                  debugPrint('❌ InvalidEmailSignin errorComment: ${e.errorComment}');
                  ErrorDialog.show(
                    context,
                    message: "Este correo ya está asociado a otra cuenta",
                  );
                } on ConnectionTimeout catch (e) {
                  debugPrint('❌ ConnectionTimeout capturado');
                  ErrorDialog.show(
                    context,
                    message: "Tiempo de espera agotado. Verifica tu conexión a internet.",
                  );
                } on UncontrolledError catch (e) {
                  debugPrint('❌ UncontrolledError capturado: ${e.message}');
                  ErrorDialog.show(
                    context,
                    message: e.message ?? "Error al verificar el correo electrónico",
                  );
                } catch (e) {
                  debugPrint('❌ Exception general capturada: $e');
                  debugPrint('❌ Tipo de excepción: ${e.runtimeType}');
                  ErrorDialog.show(
                    context,
                    message: "Error inesperado al verificar el correo electrónico",
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
