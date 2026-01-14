import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/signin_form_state.dart';
import 'package:aprende_mas/views/views.dart';

class SigninFormStateNotifier extends StateNotifier<SigninFormState> {
  final Future<bool> Function(
      {required String names,
      required String lastName,
      required String secondLastName,
      required String password,
      required String role}) siginUserCallback;

  SigninFormStateNotifier({required this.siginUserCallback})
      : super(SigninFormState());

  onNameChanged(String value) {
     final newName = GenericInput.dirty(value);
     state = state.copyWith(
         name: newName,
         isValid: Formz.validate([
           newName,
           state.lastName,
           state.secondLastName,
           state.password,
           state.role
         ]));
   }

  onLastNameChanged(String value) {
    final newLastName = GenericInput.dirty(value);
    state = state.copyWith(
        lastName: newLastName,
        isValid: Formz.validate([
          state.name,
          newLastName,
          state.secondLastName,
          state.password,
          state.role
        ]));
  }

  onSecondLastNameChanged(String value) {
    final secondLastName = GenericInput.dirty(value);
    state = state.copyWith(
        secondLastName: secondLastName,
        isValid: Formz.validate([
          state.name,
          state.lastName,
          secondLastName,
          state.password,
          state.role
        ]));
  }

  // onEmailChanged(String value) {
  //   final newEmail = Email.dirty(value);
  //   state = state.copyWith(
  //       email: newEmail,
  //       isValid: Formz.validate([
  //         state.name,
  //         state.lastName,
  //         newEmail,
  //         state.password,
  //         state.role
  //       ]));
  // }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate([
          state.name,
          state.lastName,
          state.secondLastName,
          newPassword,
          state.role
        ]));
  }

  onRoleChanged(String value) {
    final newRole = Role.dirty(value);
    state = state.copyWith(
        role: newRole,
        isValid: Formz.validate([
          state.name,
          state.lastName,
          state.secondLastName,
          state.password,
          newRole
        ]));
  }

  onFormSigninSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;
    try {
      state = state.copyWith(isPosting: true);
      bool res = await siginUserCallback(
          names: state.name.value,
          lastName: state.lastName.value,
          secondLastName: state.secondLastName.value,
          password: state.password.value,
          role: state.role.value);

      if (res) {
        state = state.copyWith(isFormPosted: true, isPosting: false);
        // Limpiar formulario después de registro exitoso
        clearFormSigninState();
      } else {
        state = state.copyWith(isFormNotPosted: true, isPosting: false);
      }
    } catch (e) {
      state = state.copyWith(isFormNotPosted: true, isPosting: false);
    } finally {
      //* Reiniciamos flags pero mantenemos datos para posibles reintentos
      state = state.copyWith(
          isFormPosted: false, isFormNotPosted: false);
    }
  }

  _touchEveryField() {
    final name = GenericInput.dirty(state.name.value);
    final lastName = GenericInput.dirty(state.lastName.value);
    final secondLastName = GenericInput.dirty(state.secondLastName.value);
    final password = Password.dirty(state.password.value);
    final role = Role.dirty(state.role.value);

    state = state.copyWith(
        name: name,
        lastName: lastName,
        secondLastName: secondLastName,
        password: password,
        role: role,
        isValid: Formz.validate([name, lastName, secondLastName, password, role]));
  }

  touchFields() {
    _touchEveryField();
  }

  clearFormSigninState() {
    state = SigninFormState();
  }
}
