import 'package:aprende_mas/views/views.dart';

class NoticesFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isDeleted;
  final GenericInput title;
  final GenericInput description;

  NoticesFormState(
      {this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.isDeleted = false,
      this.title = const GenericInput.pure(),
      this.description = const GenericInput.pure()});

  NoticesFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isDeleted,
    GenericInput? title,
    GenericInput? description,
  }) =>
      NoticesFormState(
          isPosting: isPosting ?? this.isPosting,
          isFormPosted: isFormPosted ?? this.isFormPosted,
          isValid: isValid ?? this.isValid,
          isDeleted: isDeleted ?? this.isDeleted,
          title: title ?? this.title,
          description: description ?? this.description);
}
