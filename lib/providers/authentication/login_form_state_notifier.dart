import 'package:aprende_mas/config/utils/packages.dart';
import 'login_form_state.dart';
import 'package:aprende_mas/views/views.dart';

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;
  final Function() loginUserGoogleCallback;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginFormNotifier({
    required this.loginUserCallback,
    required this.loginUserGoogleCallback,
  })  : emailController = TextEditingController(),
        passwordController = TextEditingController(),
        super(LoginFormState());

  onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
        email: newEmail, isValid: Formz.validate([newEmail, state.password]));
  }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([newPassword, state.password]),
    );
  }

  onFormSubmit() async {
    // No validar formato, solo llamar loginUser
    state = state.copyWith(isPosting: true);
    await loginUserCallback(state.email.value, state.password.value);
    state = state.copyWith(isPosting: false);
  }

  onGoogleSubmit() async {
    await loginUserGoogleCallback();
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]));
  }

  resetStateForm() {
    emailController.clear();
    passwordController.clear();
    state = LoginFormState();
  }
}
