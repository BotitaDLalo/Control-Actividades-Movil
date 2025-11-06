import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'package:aprende_mas/providers/authentication/signin_form_state.dart';
import 'package:aprende_mas/providers/authentication/signin_form_state_notifier.dart';

final signinFormProvider =
    StateNotifierProvider<SigninFormStateNotifier, SigninFormState>(
        (ref) {
  final siginUserCallback = ref.read(authProvider.notifier).signinUser;
  return SigninFormStateNotifier(siginUserCallback: siginUserCallback);
});