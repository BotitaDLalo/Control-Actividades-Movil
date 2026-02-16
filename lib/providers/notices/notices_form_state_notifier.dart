import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notices/notices_form_state.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/models/models.dart';

class NoticesFormStateNotifier extends StateNotifier<NoticesFormState> {
  final Future<bool> Function(NoticeModel) createNoticeCallback;
  final Future<bool> Function(int) deleteNoticeCallback;
  final Future<bool> Function(NoticeModel) updateNoticeCallback;
  // final Function(NoticeModel) getNoticesCallback;

  NoticesFormStateNotifier(
      {required this.createNoticeCallback, 
      required this.deleteNoticeCallback,
      required this.updateNoticeCallback
}) 
      : super(NoticesFormState());

  onTitleChanged(String value) {
    final newTitle = GenericInput.dirty(value);
    state = state.copyWith(
        title: newTitle,
        isValid: Formz.validate([newTitle, state.description, state.startDate, state.endDate, state.links, state.frequencyDays]));
  }
  onInitializeEditData(NoticeModel notice) {
    // Inicializa los campos del formulario con los valores existentes
    final initialTitle = GenericInput.dirty(notice.title);
    final initialDescription = GenericInput.dirty(notice.description);
    final initialStartDate = GenericInput.dirty(notice.startDate ?? '');
    final initialEndDate = GenericInput.dirty(notice.endDate ?? '');
    final initialLinks = GenericInput.dirty(notice.links ?? '');
    final initialFrequencyDays = GenericInput.dirty(notice.frequencyDays.toString());

    state = state.copyWith(
        noticeId: notice.noticeId, // Guardamos el ID del aviso
        title: initialTitle, 
        description: initialDescription,
        startDate: initialStartDate,
        endDate: initialEndDate,
        links: initialLinks,
        frequencyDays: initialFrequencyDays,
        isValid: true); // Si viene de edición, asumimos que es válido al inicio
  }

  onDescriptionChanged(String value) {
    final newDescription = GenericInput.dirty(value);
    state = state.copyWith(
        description: newDescription,
        isValid: Formz.validate([newDescription, state.title, state.startDate, state.endDate, state.links, state.frequencyDays]));
  }

  onStartDateChanged(String value) {
    final newStartDate = GenericInput.dirty(value);
    state = state.copyWith(
        startDate: newStartDate,
        isValid: Formz.validate([state.title, state.description, newStartDate, state.endDate, state.links, state.frequencyDays]));
  }

  onEndDateChanged(String value) {
    final newEndDate = GenericInput.dirty(value);
    state = state.copyWith(
        endDate: newEndDate,
        isValid: Formz.validate([state.title, state.description, state.startDate, newEndDate, state.links, state.frequencyDays]));
  }

  onLinksChanged(String value) {
    final newLinks = GenericInput.dirty(value);
    state = state.copyWith(
        links: newLinks,
        isValid: Formz.validate([state.title, state.description, state.startDate, state.endDate, newLinks, state.frequencyDays]));
  }

  onFrequencyDaysChanged(String value) {
    final newFrequencyDays = GenericInput.dirty(value);
    state = state.copyWith(
        frequencyDays: newFrequencyDays,
        isValid: Formz.validate([state.title, state.description, state.startDate, state.endDate, state.links, newFrequencyDays]));
  }

  Future<bool> onFormSubmit(NoticeModel createNotice) async {
    _touchEveryField();
    if (!state.isValid) return false;
    // CAMBIO: Limpiar mensaje de error antes de intentar crear
    state = state.copyWith(isPosting: true, errorMessage: '');
    createNotice = createNotice.copyWith(
        title: state.title.value, 
        description: state.description.value,
        startDate: state.startDate.value,
        endDate: state.endDate.value,
        links: state.links.value,
        frequencyDays: int.tryParse(state.frequencyDays.value) ?? 0);
    bool createdNotice = await createNoticeCallback(createNotice);
    if (createdNotice) {
      // CAMBIO: Solo marcar como exitoso si realmente se creó
      state = state.copyWith(isFormPosted: createdNotice);
    } else {
      // CAMBIO: Mostrar mensaje de error al usuario si falló
      state = state.copyWith(errorMessage: 'Error al crear el aviso. Inténtalo de nuevo.');
    }
    state = state.copyWith(isPosting: false);
    resetStates();
    return createdNotice;
  }

  // 🚨 AÑADIDO: LÓGICA PARA ACTUALIZAR AVISO
  Future<bool> onUpdateSubmit(NoticeModel noticeToUpdate) async {
    _touchEveryField();
    if (!state.isValid) return false;
    state = state.copyWith(isPosting: true);

    // 1. Clonar el modelo existente y actualizar solo el título y la descripción
    noticeToUpdate = noticeToUpdate.copyWith(
        title: state.title.value,
        description: state.description.value,
        startDate: state.startDate.value,
        endDate: state.endDate.value,
        links: state.links.value,
        frequencyDays: int.tryParse(state.frequencyDays.value) ?? 0);

    // 2. Llamar al callback de actualización
    bool updatedNotice = await updateNoticeCallback(noticeToUpdate);
    
    if (updatedNotice) {
      // Usamos isFormPosted para indicar éxito y pop del router
      state = state.copyWith(isFormPosted: updatedNotice);
    }
    state = state.copyWith(isPosting: false);
    resetStates(); // Opcional: limpiar los estados del formulario después
    return updatedNotice;
  }

  _touchEveryField() {
    final title = GenericInput.dirty(state.title.value);
    final description = GenericInput.dirty(state.description.value);
    final startDate = GenericInput.dirty(state.startDate.value);
    final endDate = GenericInput.dirty(state.endDate.value);
    final links = GenericInput.dirty(state.links.value);
    final frequencyDays = GenericInput.dirty(state.frequencyDays.value);

    state = state.copyWith(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        links: links,
        frequencyDays: frequencyDays,
        isValid: Formz.validate([title, description, startDate, endDate, links, frequencyDays]));
  }

  Future<bool> onDeleteSubmit(int noticeId) async {
    state = state.copyWith(isPosting: true);
    bool noticeDeleted = await deleteNoticeCallback(noticeId);
    if (noticeDeleted) {
      state = state.copyWith(isDeleted: noticeDeleted);
    }
    state = state.copyWith(isPosting: false);
    resetStates();
    return noticeDeleted;
  }

  resetStates() {
    //$ restablece estados
    state = state.copyWith(isFormPosted: false);
    state = state.copyWith(isDeleted: false);
    // CAMBIO: Limpiar mensaje de error también
    state = state.copyWith(errorMessage: '');
  }
  
   void initializeForm(NoticeModel notice) {
    state = state.copyWith(
      title: GenericInput.dirty(notice.title),
      description: GenericInput.dirty(notice.description),
      startDate: GenericInput.dirty(notice.startDate ?? ''),
      endDate: GenericInput.dirty(notice.endDate ?? ''),
      links: GenericInput.dirty(notice.links ?? ''),
      frequencyDays: GenericInput.dirty(notice.frequencyDays.toString()),
      isValid: true, // Si viene de edición, asumimos que es válido al inicio
    );
  }

}
