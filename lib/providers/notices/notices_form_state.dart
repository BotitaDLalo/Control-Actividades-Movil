import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/views.dart';

class NoticesFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isDeleted;
  final GenericInput title;
  final GenericInput description;
  final GenericInput startDate;
  final GenericInput endDate;
  final GenericInput links;
  final GenericInput frequencyDays;
  final int noticeId;
  // CAMBIO: Campo agregado para mostrar mensajes de error al usuario
  // cuando falla la creación/actualización de avisos
  final String errorMessage;

  NoticesFormState(
      {this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.isDeleted = false,
      this.title = const GenericInput.pure(),
      this.description = const GenericInput.pure(),
      this.startDate = const GenericInput.pure(),
      this.endDate = const GenericInput.pure(),
      this.links = const GenericInput.pure(),
      this.frequencyDays = const GenericInput.pure(),
      this.noticeId = 0,
      this.errorMessage = ''});

  NoticesFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isDeleted,
    GenericInput? title,
    GenericInput? description,
    GenericInput? startDate,
    GenericInput? endDate,
    GenericInput? links,
    GenericInput? frequencyDays,
    int? noticeId,
    // CAMBIO: Parámetro agregado para actualizar errorMessage
    String? errorMessage,
  }) =>
      NoticesFormState(
          isPosting: isPosting ?? this.isPosting,
          isFormPosted: isFormPosted ?? this.isFormPosted,
          isValid: isValid ?? this.isValid,
          isDeleted: isDeleted ?? this.isDeleted,
          title: title ?? this.title,
          description: description ?? this.description,
          startDate: startDate ?? this.startDate,
          endDate: endDate ?? this.endDate,
          links: links ?? this.links,
          frequencyDays: frequencyDays ?? this.frequencyDays,
          noticeId: noticeId ?? this.noticeId,
          errorMessage: errorMessage ?? this.errorMessage);
}