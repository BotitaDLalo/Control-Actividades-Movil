import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/buttons/button_login.dart';

class FormForgotPassword extends ConsumerWidget {
  const FormForgotPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPassword = ref.watch(forgotPasswordFormProvider);
    final forgotPasswordNotifier =
        ref.read(forgotPasswordFormProvider.notifier);

    returnLogin() {
      context.pop();
    }

    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            /*
            const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(fontSize: 24),
            ),
            */
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: SvgPicture.asset(
                'assets/icons/email.svg',
                width: 20,
                height: 20,
                color: const Color.fromARGB(255, 12, 129, 231),
              ),
              label: '  Correo',
              textEditingController: forgotPasswordNotifier.emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: forgotPasswordNotifier.onEmailChanged,
              errorMessage: forgotPassword.isFormPosted
                  ? forgotPassword.email.errorMessage
                  : null,
            ),
            const SizedBox(
              height: 65,
            ),
            SizedBox(
              //width: double.infinity,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.080,
              child: ButtonLogin(
                  //buttonStyle: AppTheme.buttonPrimary,
                  
                  textColor: const Color.fromARGB(255, 6, 6, 6),
                  text: "Enviar",
                  onPressed: () async {
                    final bool? result =
                        await forgotPasswordNotifier.onFormSubmit();
                    if (result == true) {
                      returnLogin();
                    } else {
                      return;
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
