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
        isValid: Formz.validate([newTitle, state.description]));
  }
  onInitializeEditData(int noticeId, String title, String description) {
    // Inicializa los campos del formulario con los valores existentes
    final initialTitle = GenericInput.dirty(title);
    final initialDescription = GenericInput.dirty(description);

    state = state.copyWith(
        noticeId: noticeId, // Guardamos el ID del aviso
        title: initialTitle, 
        description: initialDescription,
        isValid: Formz.validate([initialTitle, initialDescription]));
  }

  onDescriptionChanged(String value) {
    final newDescription = GenericInput.dirty(value);
    state = state.copyWith(
        description: newDescription,
        isValid: Formz.validate([newDescription, state.title]));
  }

  onFormSubmit(NoticeModel createNotice) async {
    _touchEveryField();
    if (!state.isValid) return;
    // CAMBIO: Limpiar mensaje de error antes de intentar crear
    state = state.copyWith(isPosting: true, errorMessage: '');
    createNotice = createNotice.copyWith(
        title: state.title.value, description: state.description.value);
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
  }

  // 🚨 AÑADIDO: LÓGICA PARA ACTUALIZAR AVISO
  onUpdateSubmit(NoticeModel noticeToUpdate) async {
    _touchEveryField();
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);

    // 1. Clonar el modelo existente y actualizar solo el título y la descripción
    noticeToUpdate = noticeToUpdate.copyWith(
        title: state.title.value, 
        description: state.description.value);

    // 2. Llamar al callback de actualización
    bool updatedNotice = await updateNoticeCallback(noticeToUpdate);
    
    if (updatedNotice) {
      // Usamos isFormPosted para indicar éxito y pop del router
      state = state.copyWith(isFormPosted: updatedNotice);
    }
    state = state.copyWith(isPosting: false);
    resetStates(); // Opcional: limpiar los estados del formulario después
  }

  _touchEveryField() {
    final title = GenericInput.dirty(state.title.value);
    final description = GenericInput.dirty(state.description.value);

    state = state.copyWith(
        title: title,
        description: description,
        isValid: Formz.validate([title, description]));
  }

  onDeleteSubmit(int noticeId) async {
    state = state.copyWith(isPosting: true);
    bool noticeDeleted = await deleteNoticeCallback(noticeId);
    if (noticeDeleted) {
      state = state.copyWith(isDeleted: noticeDeleted);
    }
    state = state.copyWith(isPosting: false);
    resetStates();
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
      isValid: true, // Si viene de edición, asumimos que es válido al inicio
    );
  }

}
