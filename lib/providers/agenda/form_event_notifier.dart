import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/agenda/form_event_state.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/inputs/color_input.dart';

class FormEventNotifier extends StateNotifier<FormEventState>{
  final Function(String, String, Color, DateTime, DateTime, {List<int>? groupIds, List<int>? subjectIds}) eventCallback;
  final TextEditingController titleController; 
  final TextEditingController descriptionController;
  final TextEditingController startTimeController; 
  final TextEditingController startDateController;
  final TextEditingController endTimeController;
  final TextEditingController endDateController; 
  final TextEditingController colorController;  

  FormEventNotifier({
    required this.eventCallback,
    })
    : titleController = TextEditingController(),
      descriptionController = TextEditingController(),
      startDateController = TextEditingController(),
      startTimeController = TextEditingController(),
      endDateController = TextEditingController(),
      endTimeController = TextEditingController(),
      colorController = TextEditingController(),
      super(FormEventState());

void onTitleChanged(String value) {
  final newTitle = GenericInput.dirty(value);
  state = state.copyWith(
    title: newTitle, 
    isValid: Formz.validate([
      newTitle, 
      state.description,
      state.startDate, 
      state.startTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ])
  );
}

void onDescriptionChanged(String value) {
  final newDescription = GenericInput.dirty(value);
  state = state.copyWith(
    description: newDescription,
    isValid: Formz.validate([
      state.title, 
      newDescription,
      state.startDate,
      state.startTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ])
  );
}

void onStartDateChanged(String value) {
  final newStartDate = GenericInput.dirty(value);
  state = state.copyWith(
    startDate: newStartDate,
    isValid: Formz.validate([
      state.title,
      state.description, 
      newStartDate,
      state.startTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ])
  );
}

void onStartTimeChanged(String value) {
  final newStartTime = GenericInput.dirty(value);
  state = state.copyWith(
    startTime: newStartTime,
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      newStartTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ])
  );
}

void onEndDatechanged(String value) {
  final newEndDate = GenericInput.dirty(value);
  state = state.copyWith(
    endDate: newEndDate,
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      state.startTime,
      newEndDate,
      state.endTime,
      state.colorCode
    ])
  );
}

void onEndTimechanged(String value) {
  final newEndTime = GenericInput.dirty(value);
  state = state.copyWith(
    endTime: newEndTime, // ← Se corrigió la asignación incorrecta
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      state.startTime,
      state.endDate,
      newEndTime,
      state.colorCode
    ])
  );
}

void onColorCodeChanged(Color color) {
  final newColorCode = ColorInput.dirty(color);
  state = state.copyWith(
    colorCode: newColorCode,
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      state.startTime,
      state.endDate,
      state.endTime,
      newColorCode
    ])
  );
}

void onGroupIdsChanged(List<int> ids) {
  print(ids);
  state = state.copyWith(
    groupIds: ids, // Manteniendo el nombre original
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      state.startTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ]),
  );
}

void onSubjectIdsChanged(List<int> ids) {
  print(ids);
  state = state.copyWith(
    subjectIds: ids, // Manteniendo el nombre original
    isValid: Formz.validate([
      state.title,
      state.description,
      state.startDate,
      state.startTime,
      state.endDate,
      state.endTime,
      state.colorCode
    ]),
  );
}

DateTime? concatenarFechaHora(String fechaStr, String horaStr) {
  try {
    // Validar la fecha
    if (fechaStr.isEmpty) {
      throw Exception("La fecha es nula o está vacía");
    }
    final fecha = DateTime.tryParse(fechaStr);
    if (fecha == null) {
      throw Exception("Formato de fecha inválido: $fechaStr");
    }

    // Validar la hora
    if (horaStr.isEmpty) {
      throw Exception("La hora es nula o está vacía");
    }
    final horaParts = horaStr.split(':');
    if (horaParts.length != 2) {
      throw Exception("Formato de hora inválido: $horaStr");
    }
    final hora = int.tryParse(horaParts[0]) ?? 0;
    final minuto = int.tryParse(horaParts[1]) ?? 0;

    // Retornar la fecha y hora combinadas
    return DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);
  } catch (e) {
    return null; // Retorna null si hay un error
  }
}

Future<void> onFormSubmit() async {
  _touchEveryField();
  if (!state.isValid) return;

  if (state.groupIds!.isEmpty && state.subjectIds!.isEmpty) {
    throw Exception("Debes seleccionar un grupo o una materia.");
  }

  // Obtener la fecha y hora concatenadas
  final fechaInicio = concatenarFechaHora(state.startDate.value, state.startTime.value);
  final fechaFinal = concatenarFechaHora(state.endDate.value, state.endTime.value);

  if (fechaInicio == null || fechaFinal == null) {
    throw Exception("Las fechas y horas no pueden ser nulas");
  }

  state = state.copyWith(isPosting: true);

  try {
    bool res = await eventCallback(
      state.title.value,
      state.description.value,
      state.colorCode.value,
      fechaInicio,
      fechaFinal,
      groupIds: state.groupIds!.isNotEmpty ? List<int>.from(state.groupIds!) : null,
      subjectIds: state.subjectIds!.isNotEmpty ? List<int>.from(state.subjectIds!) : null,
    );

    print("res: $res");

    state = state.copyWith(isFormPosted: res);
  } catch (e) {
    throw Exception("Error durante la petición: $e");
  } finally {
    // Marcar el fin de la petición y resetear el formulario si fue exitoso
    state = state.copyWith(isPosting: false);
    if (state.isFormPosted) {
      resetStateForm();
    }
  }
}
  

void _touchEveryField() {
  final title = GenericInput.dirty(state.title.value);
  final description = GenericInput.dirty(state.description.value);
  final startDate = GenericInput.dirty(state.startDate.value);
  final startTime = GenericInput.dirty(state.startTime.value);
  final endDate = GenericInput.dirty(state.endDate.value);
  final endTime = GenericInput.dirty(state.endTime.value);
  final colorCode = ColorInput.dirty(state.colorCode.value);

  final List<int> groups = List<int>.from(state.groupIds ?? []);
  final List<int> subjects = List<int>.from(state.subjectIds ?? []);

  final bool isValidGroup = groups.isNotEmpty;
  final bool isValidSubject = subjects.isNotEmpty;

  if (!isValidGroup && !isValidSubject) {
    // Si ambos están vacíos, no es válido
    state = state.copyWith(
      title: title,
      description: description,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
      colorCode: colorCode,
      groupIds: groups,
      subjectIds: subjects,
      isValid: false, // Indica que el formulario no es válido
    );
    return;
  }

  state = state.copyWith(
    title: title,
    description: description,
    startDate: startDate,
    startTime: startTime,
    endDate: endDate,
    endTime: endTime,
    colorCode: colorCode,
    groupIds: groups,
    subjectIds: subjects,
    isValid: Formz.validate([
      title,
      description,
      startDate,
      startTime,
      endDate,
      endTime,
      colorCode,
    ]), 
  );
}

  void resetStateForm() {
    titleController.clear();
    descriptionController.clear();
    startDateController.clear();
    startTimeController.clear();
    endDateController.clear();
    endTimeController.clear();
    colorController.clear();
  }


}
