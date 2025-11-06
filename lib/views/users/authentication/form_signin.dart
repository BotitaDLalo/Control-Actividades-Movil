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

    // Listener unificado para manejar los efectos secundarios del estado del formulario.
    ref.listen(signinFormProvider, (previous, next) {
      final wasPosting = previous?.isPosting ?? false;

      // Muestra la pantalla de carga solo cuando se inicia el proceso de envío.
      if (!wasPosting && next.isPosting) {
        showLoadingScreen(context);
      }

      // Oculta la pantalla de carga cuando el envío ha terminado.
      if (wasPosting && !next.isPosting) {
        // Cierra el diálogo de carga. Usamos rootNavigator para evitar problemas con navegadores anidados.
        Navigator.of(context, rootNavigator: true).pop();

        // Si el formulario se envió con éxito, navega a la pantalla de confirmación.
        if (next.isFormPosted) {
          context.push('/confirmation-code-screen');
        }
      }
    });

    // Listener para mostrar errores provenientes del proveedor de autenticación.
    ref.listen(authProvider, (previous, next) {
      final errorMessage = next.errorMessage;
      final oldErrorMessage = previous?.errorMessage ?? '';

      // Muestra el SnackBar solo si hay un mensaje de error nuevo y no vacío.
      if (errorMessage.isNotEmpty && errorMessage != oldErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    });

    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: const Icon(
                Icons.person,
                size: 25,
              ),
              label: "Nombres",
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
                    icon: const Icon(
                      Icons.person,
                      size: 25,
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
                    icon: const Icon(
                      Icons.person,
                      size: 25,
                    ),
                    label: "Apellido Materno",
                    onChanged: signinFormNotifier.onSecondLastNameChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: const Icon(
                Icons.password,
                size: 25,
              ),
              label: 'Contraseña',
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
              icon: const Icon(
                Icons.group,
                size: 25,
              ),
              label: 'Elige tu rol',
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
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.060,
              child: ButtonLogin(
                text: 'Crear cuenta', // Texto más descriptivo
                textColor: Colors.white,
                // Deshabilita el botón mientras se está procesando para evitar doble clic.
                onPressed: signinForm.isPosting
                    ? null
                    : () => signinFormNotifier.onFormSigninSubmit(),
                buttonStyle: AppTheme.buttonPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
