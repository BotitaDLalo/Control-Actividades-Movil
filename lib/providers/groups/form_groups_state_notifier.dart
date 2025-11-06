import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/form_groups_state.dart';
import 'package:aprende_mas/views/widgets/inputs/inputs.dart';
import '../../models/models.dart';

class FormGroupsStateNotifier extends StateNotifier<FormGroupsState> {
  // final Function(String, String, Color) createGroupCallback;
  // final Function(String, String, Color, List<SubjectsRow>)
  //     createGroupSubjectsCallback;
  final Function(String, String, List<SubjectsRow>) createGroupSubjectsCallback;
  final Function(int, String, String) updateGroupCallback;
  // final Function(String) verifyEmailCallback;
  // final Function(int) addStudentsGroupCallback;

  FormGroupsStateNotifier({
    required this.createGroupSubjectsCallback,
    required this.updateGroupCallback,
    // required this.verifyEmailCallback,
    // required this.addStudentsGroupCallback
  }) : super(FormGroupsState());

//#FORMULARIO PARA CREACION DE UN GRUPO
  onGroupNameChanged(String value) {
    final newGroupName = GenericInput.dirty(value);
    state = state.copyWith(
        groupName: newGroupName,
        isValid: Formz.validate([newGroupName, state.colorCode]));
  }

  onDescriptionChanged(String value) {
    final newDescription = GenericInput.dirty(value);
    state = state.copyWith(
        description: newDescription,
        isValid: Formz.validate([state.groupName, state.colorCode]));
  }

  // onColorCodeChanged(Color color) {
  //   final newColorCode = ColorInput.dirty(color);
  //   state = state.copyWith(
  //       pickerColor: color,
  //       colorCode: newColorCode,
  //       isValid: Formz.validate([state.groupName, state.colorCode]));
  // }

  onFormSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);
    if (state.subjectsRow.isNotEmpty) {
      bool res = await createGroupSubjectsCallback(
          state.groupName.value, state.description.value, state.subjectsRow);
      state = state.copyWith(isFormPosted: res);
    }
    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final groupName = GenericInput.dirty(state.groupName.value);
    final description = GenericInput.dirty(state.description.value);
    // final colorCode = ColorInput.dirty(state.colorCode.value);

    state = state.copyWith(
        groupName: groupName,
        description: description,
        // colorCode: colorCode,
        isValid: Formz.validate([groupName]));
  }

//#FORMULARIO PARA CREAR UNA MATERIA  DENTRO DEL FORMULARIO DE CREACION DE UN GRUPO
  onSubjectNameChanged(String value) {
    final newSubjectName = GenericInput.dirty(value);
    state = state.copyWith(
        subjectName: newSubjectName,
        isValid: Formz.validate([state.subjectName]));
  }

  onSubjectDescription(String value) {
    final newSubjectDescription = GenericInput.dirty(value);
    state = state.copyWith(subjectDescription: newSubjectDescription);
  }

  onSubjectSubmit() {
    _subjectTouchEveryField();
    if (!state.isValid) return;
    final newSubject = SubjectsRow(
        nombreMateria: state.subjectName.value,
        descripcion: state.subjectDescription.value);
    state = state.copyWith(subjectsRow: [newSubject, ...state.subjectsRow]);
    resetFormSubjects();
  }

  void resetFormSubjects() {
    const resetFormSubjects = GenericInput.pure();
    state = state.copyWith(
        subjectName: resetFormSubjects,
        subjectDescription: resetFormSubjects,
        isValid: false);
  }

  _subjectTouchEveryField() {
    final subjectName = GenericInput.dirty(state.subjectName.value);
    final subjectDescription =
        GenericInput.dirty(state.subjectDescription.value);

    state = state.copyWith(
        isFormPosted: true,
        subjectName: subjectName,
        subjectDescription: subjectDescription);
  }

  //# FORMULARIO PARA ACTUALIZAR UNA MATERIA CREADA DENTRO DEL FORMULARIO DE CREACION DE UN GRUPO
  onUpdateIndexSubjChanged(int value) {
    state = state.copyWith(subjectIndex: value);
  }

  onUpdateSubjNameChanged(String value) {
    final newSubjectName = GenericInput.dirty(value);
    state = state.copyWith(subjectName: newSubjectName);
  }

  onUpdateSubjDescriptionChanged(String value) {
    final newDescriptionName = GenericInput.dirty(value);
    state = state.copyWith(subjectDescription: newDescriptionName);
  }

  onUpdateSubjectsSubmit() {
    List<SubjectsRow> subjectsList = List.from(state.subjectsRow);
    final indexSubject = state.subjectIndex;
    final newSubjectName = state.subjectName.value;
    final newSubjectDescription = state.subjectDescription.value;

    subjectsList[indexSubject] = SubjectsRow(
        nombreMateria: newSubjectName, descripcion: newSubjectDescription);
  }

  //# FORMULARIO PARA ACTUALIZAR UN GRUPO

  onGroupId(int value) {
    state = state.copyWith(groupId: value);
  }

  onUpdateGroupNameChanged(String value) {
    final newGroupName = GenericInput.dirty(value);
    state = state.copyWith(
        groupName: newGroupName, isValid: Formz.validate([state.groupName]));
  }

  onUpdateGroupDescriptionChanged(String value) {
    final newGroupDescription = GenericInput.dirty(value);
    state = state.copyWith(
        description: newGroupDescription,
        isValid: Formz.validate([state.description]));
  }

  // onUpdateGroupColorChanged(Color color) {
  //   final newGroupColor = ColorInput.dirty(color);
  //   state = state.copyWith(
  //       pickerColor: color,
  //       colorCode: newGroupColor,
  //       isValid: Formz.validate([state.colorCode]));
  // }

  onUpdateGroupSubmit(
    int groupId,
    String groupName,
    String description,
  ) async {
    onGroupId(groupId);
    _updateGroupTouchEveryField(groupId, groupName, description);
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);
    bool res = await updateGroupCallback(
        state.groupId, state.groupName.value, state.description.value);
    state = state.copyWith(isFormPosted: res);
    state = state.copyWith(isPosting: false);
  }

  _updateGroupTouchEveryField(
      int groupId, String groupName, String description) {
    final groupNameInput = GenericInput.dirty(
        state.groupName.value == "" ? groupName : state.groupName.value);
    final groupDescriptionInput = GenericInput.dirty(
        state.description.value == "" ? description : state.description.value);

    // final colorCodeStr = state.pickerColor;
    // final String hexColor = colorCodeStr.value.toRadixString(16).toUpperCase();

    // final colorGroup = hexColor == "FFFFFF"
    //     ? AppTheme.stringToColor(colorCode)
    //     : state.pickerColor;

    // final groupColorInput = ColorInput.dirty(colorGroup);

    state = state.copyWith(
        groupName: groupNameInput,
        description: groupDescriptionInput,
        // colorCode: groupColorInput,
        isValid: Formz.validate([groupNameInput]) ||
            Formz.validate([groupDescriptionInput])
        // ||Formz.validate([groupColorInput])
        );
  }
}
