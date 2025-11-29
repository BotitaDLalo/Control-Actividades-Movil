import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/views.dart';

class NoticesFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isDeleted;
  final GenericInput title;
  final GenericInput description;
  final int noticeId; // ⬅️ 1. CAMPO AÑADIDO para el ID del aviso

  NoticesFormState(
      {this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.isDeleted = false,
      this.title = const GenericInput.pure(),
      this.description = const GenericInput.pure(),
      this.noticeId = 0}); // ⬅️ 2. VALOR POR DEFECTO AÑADIDO (0 indica que no ha sido creado)

  NoticesFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isDeleted,
    GenericInput? title,
    GenericInput? description,
    int? noticeId, // ⬅️ 3. PARÁMETRO AÑADIDO al copyWith
  }) =>
      NoticesFormState(
          isPosting: isPosting ?? this.isPosting,
          isFormPosted: isFormPosted ?? this.isFormPosted,
          isValid: isValid ?? this.isValid,
          isDeleted: isDeleted ?? this.isDeleted,
          title: title ?? this.title,
          description: description ?? this.description,
          noticeId: noticeId ?? this.noticeId); // ⬅️ 4. IMPLEMENTACIÓN AÑADIDA
}