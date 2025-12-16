import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/button_login.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_dropdown.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/providers/providers.dart';

class FormMissingData extends ConsumerStatefulWidget {
  const FormMissingData({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormMissingDataState();
}

class _FormMissingDataState extends ConsumerState<FormMissingData> {
  @override
  Widget build(BuildContext context) {
    final missingDataNotifier = ref.read(missingDataFormProvider.notifier);
    final missingData = ref.watch(missingDataFormProvider);
    final cn = CatalogNames();
    final List<String> users = [cn.getRoleStudentName, cn.getRoleTeacherName];

    void goToConfirmationCodeScreen() {
      Navigator.of(context).pop();
      context.push('/confirmation-code-screen');
    }

    ref.listen(
      missingDataFormProvider,
      (previous, next) {
        if (next.isPosting) {
          showLoadingScreen(context);
        }
      },
    );

    ref.listen(
      missingDataFormProvider,
      (previous, next) {
        if (next.isFormPosted && !next.isPosting) {
          goToConfirmationCodeScreen();
        }
      },
    );

    ref.listen(
      authProvider,
      (previous, next) {
        if (next.errorMessage.isNotEmpty) {
          if (next.errorHandlingStyle == ErrorHandlingStyle.snackBar) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ErrorDialog.show(context, message: next.errorMessage);
          }
        }
      },
    );
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Datos faltantes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              icon: const Icon(
                Icons.person,
                size: 25,
              ),
              label: "Nombres",
              onChanged: missingDataNotifier.onUsernameChanged,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              icon: const Icon(
                Icons.person,
                size: 25,
              ),
              label: "Apellido Paterno",
              onChanged: missingDataNotifier.onLastNameChanged,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              icon: const Icon(
                Icons.person,
                size: 25,
              ),
              label: "Apellido Materno",
              onChanged: missingDataNotifier.onSecondLastNameChanged,
            ),
            const SizedBox(
              height: 20,
            ),
            // const RoleDropdown(),
            CustomDropdown(
              icon: const Icon(
                Icons.group,
                size: 25,
              ),
              label: 'Elige tu rol',
              items: users,
              onChanged: (p0) {
                missingDataNotifier.onRoleChanged(p0);
              },
            ),
            const SizedBox(
              height: 65,
            ),
            ButtonLogin(
              text: 'Continuar',
              textColor: Colors.white,
              onPressed: () {
                if (missingData.isPosting) {
                  return;
                }
                missingDataNotifier.onFormSubmit();
              },
              buttonStyle: AppTheme.buttonPrimary,
            )
            // ButtonForm(
            //     style: AppTheme.buttonPrimary,
            //     buttonName: "Continuar",
            //     onPressed: () {
            //       missingDataNotifier.onFormSubmit();
            //     })
          ],
        ),
      ),
    );
  }
}
