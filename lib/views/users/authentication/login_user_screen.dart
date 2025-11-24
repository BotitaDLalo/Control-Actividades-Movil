import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/views/users/authentication/form_login.dart';
import 'package:aprende_mas/views/widgets/alerts/error_snackbar.dart';
import 'package:aprende_mas/providers/providers.dart';

class LoginUserScreen extends ConsumerWidget {
  const LoginUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showErrorMessage(String message) {
      errorMessage(context, message);
    }

    hideSnackBar() {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    ref.listen(
      authProvider,
      (previous, next) {
        if (next.theresMissingData) {
          context.go("/missing-data");
        }
      },
    );

    ref.listen(
      authProvider,
      (previous, next) {
        if (next.isPendingAuthorizationUser) {
          context.go('/confirmation-code-screen');
        }
      },
    );

    ref.listen(
      authProvider,
      (previous, next) {
        if (next.errorMessage.isNotEmpty) {
          if (next.errorHandlingStyle == ErrorHandlingStyle.snackBar) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            hideSnackBar();
            showErrorMessage(next.errorMessage);
          }
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color.fromARGB(255, 241, 249, 253),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(0, 35, 234, 184),
              elevation: 0,
            ),
            body: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      /*
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(73, 33, 200, 251),
                        shape: BoxShape.circle,
                      ),
                      */
                      // Aqui ira el logo de la app posteriormente
                      child: SvgPicture.asset(
                        'assets/icons/logo1.svg',
                        width: 100,
                        height: 100,
                        //color: const Color.fromARGB(255, 18, 146, 245),
                      ),
                    ),
                    const SizedBox(height: 0),
                    const FormLogin(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
