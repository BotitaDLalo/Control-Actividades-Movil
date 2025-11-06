import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'package:aprende_mas/views/users/authentication/form_confirmation_code.dart';

class ConfirmationCodeScreen extends ConsumerWidget {
  const ConfirmationCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              ref.read(authProvider.notifier).popAuth();
              context.go('/');
            },
          ),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [FormConfirmationCode()],
          ),
        ),
      ),
    );
  }
}
