import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/users/authentication/verify_email_signin_form.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';

class VerifyEmailSigninScreen extends ConsumerWidget {
  const VerifyEmailSigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // notifier not required here; kept if needed in the future
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBarHome(title: 'Verificar correo', showSettings: false),
            body: const SingleChildScrollView(
              child: Column(
                children: [VerifyEmailSigninForm()],
              ),
            ),
          )
        ],
      ),
    );
  }
}
