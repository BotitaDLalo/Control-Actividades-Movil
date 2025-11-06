import 'package:intl/intl.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/providers/agenda/form_event_state.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/inputs/color_input.dart';

class FormUpdateEventNotifier extends StateNotifier<FormEventState>{
  final Function(Map<String, dynamic> eventLike)? updateEventCallback;

  FormUpdateEventNotifier({
    required this.updateEventCallback,
    required Event event
    })
    : super(FormEventState(
        title: GenericInput.dirty(event.title),
        description: GenericInput.dirty(event.description),
        startDate: GenericInput.dirty(formatOnlyDate(event.startDate.toString())),
        startTime: GenericInput.dirty(formatOnlyTime(event.startDate.toString())),
        endDate: GenericInput.dirty(formatOnlyDate(event.endDate.toString())),
        endTime: GenericInput.dirty(formatOnlyTime(event.endDate.toString())),
        colorCode: ColorInput.dirty(_parseColor(event.color)),
        groupIds: event.groupIds,
        subjectIds: event.subjectIds
      ));

  

  static Color _parseColor(String colorString) {
  colorString = colorString.replaceAll("#", ""); // Eliminamos el `#` si existe
  if (colorString.length == 6) {
    return Color(int.parse("0xFF$colorString")); // Se agrega el prefijo `0xFF`
  } else if (colorString.length == 8) {
    return Color(int.parse("0x$colorString")); // Si ya tiene `FF`, se usa tal cual
  } else {
    return Colors.black; // Color por defecto si el formato no es válido
  }
}

  onUpdateTitleChanged(String value) {
    state = state.copyWith(
      title: GenericInput.dirty(value),
      isValid: Formz.validate([
        GenericInput.dirty(value),
        GenericInput.dirty(state.description.value),
        GenericInput.dirty(state.startDate.value),
        GenericInput.dirty(state.startTime.value),
        GenericInput.dirty(state.endDate.value),
        GenericInput.dirty(state.endTime.value),
        ColorInput.dirty(state.colorCode.value)
      ]) 
    );
  }

  onUpdateDescriptionChanged(String value) {
    state = state.copyWith(
      description:  GenericInput.dirty(value),
      isValid: Formz.validate([
        GenericInput.dirty(state.title.value),
        GenericInput.dirty(value),
        GenericInput.dirty(state.startDate.value),
        GenericInput.dirty(state.startTime.value),
        GenericInput.dirty(state.endDate.value),
        GenericInput.dirty(state.endTime.value),
        ColorInput.dirty(state.colorCode.value)
      ])
    );
  }

  onUpdateStartDateChanged(String value) {
    state = state.copyWith(
      startDate: GenericInput.dirty(value),
      isValid: Formz.validate([
        GenericInput.dirty(state.title.value),
        GenericInput.dirty(state.description.value),
        GenericInput.dirty(value),
        GenericInput.dirty(state.startTime.value),
        GenericInput.dirty(state.endDate.value),
        GenericInput.dirty(state.endTime.value),
        ColorInput.dirty(state.colorCode.value)
      ])
    );
  } 

  onUpdateStartTimeChanged(String value) {
    state = state.copyWith(
      startTime: GenericInput.dirty(value),
      isValid: Formz.validate([
          GenericInput.dirty(state.title.value),
          GenericInput.dirty(state.description.value),
          GenericInput.dirty(state.startDate.value),
          GenericInput.dirty(value),
          GenericInput.dirty(state.endDate.value),
          GenericInput.dirty(state.endTime.value),
          ColorInput.dirty(state.colorCode.value)
      ])
    );
  } 
  
  onUpdateEndDateChanged(String value) {
    state = state.copyWith(
      endDate: GenericInput.dirty(value),
      isValid: Formz.validate([
          GenericInput.dirty(state.title.value),
          GenericInput.dirty(state.description.value),
          GenericInput.dirty(state.startDate.value),
          GenericInput.dirty(state.startTime.value),
          GenericInput.dirty(value),
          GenericInput.dirty(state.endTime.value),
          ColorInput.dirty(state.colorCode.value)
      ])
    );
  }

  onUpdateEndTimeChanged(String value) {
    state = state.copyWith(
      endTime: GenericInput.dirty(value),
      isValid: Formz.validate([
          GenericInput.dirty(state.title.value),
          GenericInput.dirty(state.description.value),
          GenericInput.dirty(state.startDate.value),
          GenericInput.dirty(state.startTime.value),
          GenericInput.dirty(state.endDate.value),
          GenericInput.dirty(value),
          ColorInput.dirty(state.colorCode.value)
      ])
    );
  } 

  onUpdateGroupColorChanged(Color color) {
    state = state.copyWith(
      colorCode: ColorInput.dirty(color),
      isValid: Formz.validate([
        GenericInput.dirty(state.title.value),
        GenericInput.dirty(state.description.value),
        GenericInput.dirty(state.startDate.value),
        GenericInput.dirty(state.startTime.value),
        GenericInput.dirty(state.endDate.value),
        GenericInput.dirty(state.endTime.value),
        ColorInput.dirty(color)
      ])
    );
  }

  void onUpdateGroupIdsChanged(List<int> ids) {
  state = state.copyWith(
    groupIds: ids, // Manteniendo el nombre original
    isValid: Formz.validate([
      GenericInput.dirty(state.title.value),
      GenericInput.dirty(state.description.value),
      GenericInput.dirty(state.startDate.value),
      GenericInput.dirty(state.startTime.value),
      GenericInput.dirty(state.endDate.value),
      GenericInput.dirty(state.endTime.value),
      ColorInput.dirty(state.colorCode.value)
    ]),
  );
}

void onUpdateSubjectIdsChanged(List<int> ids) {
  state = state.copyWith(
    subjectIds: ids, // Manteniendo el nombre original
    isValid: Formz.validate([
      GenericInput.dirty(state.title.value),
      GenericInput.dirty(state.description.value),
      GenericInput.dirty(state.startDate.value),
      GenericInput.dirty(state.startTime.value),
      GenericInput.dirty(state.endDate.value),
      GenericInput.dirty(state.endTime.value),
      ColorInput.dirty(state.colorCode.value)
    ]),
  );
}

DateTime? concatenarFechaHora(String fechaStr, String horaStr) {
  try {
    print("🔹 Input fecha: $fechaStr, hora: $horaStr");

    // Validar la fecha
    if (fechaStr.isEmpty) throw Exception("La fecha es nula o está vacía");
    final fecha = DateFormat("dd-MM-yyyy").parse(fechaStr);

    // Validar la hora
    if (horaStr.isEmpty) throw Exception("La hora es nula o está vacía");
    final horaParts = horaStr.split(':');
    if (horaParts.length != 2) throw Exception("Formato de hora inválido: $horaStr");

    final hora = int.tryParse(horaParts[0]) ?? 0;
    final minuto = int.tryParse(horaParts[1]) ?? 0;

    // Crear DateTime con la fecha y hora
    final resultado = DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);

    print("✅ Fecha concatenada: $resultado");
    return resultado;
  } catch (e) {
    print("❌ Error en concatenarFechaHora: $e");
    return null;
  }
}

// String colorToHex(Color color) {
//   return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
// }


Future<bool> onUpdateFormSubmit(int eventId, int teacherId) async {
  try {
    _updatetouchEveryField();
  if (!state.isValid) return false;
  if (updateEventCallback == null) return false;

  // if (state.groupIds!.isEmpty && state.subjectIds!.isEmpty) {
  //   throw Exception("Debes seleccionar un grupo o una materia.");
  // }

  // Obtener la fecha y hora concatenadas
  final fechaInicio = concatenarFechaHora(state.startDate.value, state.startTime.value);
  final fechaFinal = concatenarFechaHora(state.endDate.value, state.endTime.value);


  String colorToHex(Color color) {
  return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
}


  // if (fechaInicio == null || fechaFinal == null) {
  //   throw Exception("Las fechas y horas no pueden ser nulas");
  // }

  final eventLike = {
    "eventoId": eventId,
    "DocenteId": teacherId,
    "FechaInicio": fechaInicio?.toIso8601String(),
    "FechaFinal": fechaFinal?.toIso8601String(),
    "Titulo": state.title.value,
    "Descripcion": state.description.value,
    "Color": colorToHex(state.colorCode.value), //"FF5733"
    "EventosGrupos": state.groupIds!.isNotEmpty ? state.groupIds!.map((id) => {"GrupoId": id}).toList() : null,
    "EventosMaterias": state.subjectIds!.isNotEmpty ? state.groupIds!.map((id) => {"MateriaId": id}).toList() : null,
  };

  print("eventLike: $eventLike");

  try {
    await updateEventCallback!(eventLike);
    return true;
  } catch (e) {
    return false;
  }


  } catch (e) {
    throw Exception("Error durante la petición: $e");
  } finally {
    // Marcar el fin de la petición y resetear el formulario si fue exitoso
    state = state.copyWith(isPosting: false);
  }
}
  
void _updatetouchEveryField() {
  final titleNameInput = GenericInput.dirty(state.title.value);
  final descriptionNameInput = GenericInput.dirty(state.description.value);
  final startDateNameInput = GenericInput.dirty(state.startDate.value);
  final startTimeNameInput = GenericInput.dirty(state.startTime.value);
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
      title: titleNameInput,
      description: descriptionNameInput,
      startDate: startDateNameInput,
      startTime: startTimeNameInput,
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
    title: titleNameInput,
    description: descriptionNameInput,
    startDate: startDateNameInput,
    startTime: startTimeNameInput,
    endDate: endDate,
    endTime: endTime,
    colorCode: colorCode,
    groupIds: groups,
    subjectIds: subjects,
    isValid: Formz.validate([
      titleNameInput,
      descriptionNameInput,
      startDateNameInput,
      startTimeNameInput,
      endDate,
      endTime,
      colorCode,
    ]), 
  );
}

}