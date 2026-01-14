import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/form_email_state.dart';
import 'package:aprende_mas/views/views.dart';

class FormEmailStateNotifier extends StateNotifier<FormEmailState> {
  final Function(String) verifyEmailSignin;
  FormEmailStateNotifier({required this.verifyEmailSignin})
      : super(FormEmailState());

  onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state =
        state.copyWith(email: newEmail, isValid: Formz.validate([newEmail]));
  }

  onVerifyEmailSigninSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);
    try {
      await verifyEmailSignin(state.email.value);
      // Si llega aquí, el email está disponible
      state = state.copyWith(isFormPosted: true);
    } catch (e) {
      debugPrint('❌ Notifier - Re-lanzando excepción: $e');
      state = state.copyWith(isPosting: false);
      rethrow; // Re-lanzar para que llegue al form
    }
    state = state.copyWith(isPosting: false);
    state = state.copyWith(isValid: false, isFormPosted: false, isFormNotPosted: false);
  }

  clearEmailSigninState() {
    state = FormEmailState();
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    state = state.copyWith(email: email, isValid: Formz.validate([email]));
  }
}
