import 'package:aprende_mas/views/widgets/inputs/inputs.dart';

class FormGroupsSubjectsState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final GenericInput codeClass;

  FormGroupsSubjectsState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.codeClass = const GenericInput.pure(),
  });

  FormGroupsSubjectsState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    GenericInput? codeClass,
  }) =>
      FormGroupsSubjectsState(
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isPosting: isPosting ?? this.isPosting,
        isValid: isValid ?? this.isValid,
        codeClass: codeClass ?? this.codeClass,
      );
}
