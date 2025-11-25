import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/views/widgets/inputs/generic_input.dart';

class ActivityFormNotifier extends StateNotifier<ActivityFormState> {
  final Function(Map<String, dynamic> activityLike)? activityCallback;
 // En la parte superior de la clase ActivityFormNotifier
  final Function(
      int activityId, 
      String nombre, 
      String descripcion, 
      DateTime fechaLimite, 
      int puntaje,   // <--- Agregamos int puntaje
      int materiaId  // <--- Agregamos int materiaId
  )? updateActivityCallback;
  
  final Function(int, String) sendSubmissionCallback;
  final Function(int, String) sendSubmissionOfflineCallback;
  final Function({required int submissionId, required int grade})
      submissionGradingCallback;
  
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final TextEditingController fechaController;
  final TextEditingController horaController;
  final TextEditingController answerController;
  final TextEditingController puntajeController;

  ActivityFormNotifier(
      {required this.activityCallback,
      required this.sendSubmissionCallback,
      required this.sendSubmissionOfflineCallback,
      required this.submissionGradingCallback,
      this.updateActivityCallback, // Agregar al constructor
      })
      : fechaController = TextEditingController(),
        horaController = TextEditingController(),
        nombreController = TextEditingController(),
        descripcionController = TextEditingController(),
        answerController = TextEditingController(),
        puntajeController = TextEditingController(),
        super(ActivityFormState());

  onNombreChanged(String value) {
    final newNombre = GenericInput.dirty(value);
    state = state.copyWith(
      nombre: newNombre,
      isValid: Formz.validate([
        newNombre,
        state.descripcion,
        state.horaLimite,
        state.fechaLimite,
        //state.puntaje
      ]),
    );
  }

  // Actualiza el campo 'descripcion'
  onDescripcionChanged(String value) {
    final newDescripcion = GenericInput.dirty(value);
    state = state.copyWith(
      descripcion: newDescripcion,
      isValid: Formz.validate([
        state.nombre,
        newDescripcion,
        state.horaLimite,
        state.fechaLimite,
        //state.puntaje
      ]),
    );
  }

  // Actualiza el campo 'fechaEntrega'
  onFechaLimiteChanged(String value) {
    final newFechaLimite = GenericInput.dirty(value);
    state = state.copyWith(
      fechaLimite: newFechaLimite,
      isValid: Formz.validate([
        state.nombre,
        state.descripcion,
        state.horaLimite,
        newFechaLimite,
        //state.puntaje
      ]),
    );
  }

// Actualiza el campo 'horaEntrega'
  onHoraLimiteChanged(String value) {
    final newHoraLimite = GenericInput.dirty(value);
    state = state.copyWith(
      horaLimite: newHoraLimite,
      isValid: Formz.validate([
        state.nombre,
        state.descripcion,
        state.fechaLimite,
        newHoraLimite,
        //state.puntaje
      ]),
    );
  }

// En activity_form_notifier.dart (alrededor de la línea 119)

onPuntajeChanged(String value) {
    
    // 🔴 NUEVA LÓGICA: Si el valor está vacío, lo consideramos 'pure' (válido sin error)
    if (value.isEmpty) { 
        state = state.copyWith(
            puntaje: const GenericInput.pure(), // <--- ESTO ES CRUCIAL
            isValid: Formz.validate([
                state.nombre,
                state.descripcion,
                state.fechaLimite,
                state.horaLimite,
                // Asegúrate de que puntaje NO esté aquí
            ]),
        );
        return; 
    }

    // Lógica para cuando el campo SÍ tiene valor
    final newPuntaje = GenericInput.dirty(value);
    
    state = state.copyWith(
        puntaje: newPuntaje,
        isValid: Formz.validate([
            state.nombre,
            state.descripcion,
            state.fechaLimite,
            state.horaLimite,
            // Asegúrate de que newPuntaje NO esté aquí
        ]),
    );
}

  DateTime? _getFechaHoraConcatenada() {
    try {
      // Obtener y parsear la fecha
      final fechaStr = state.fechaLimite.value;
      if (fechaStr.isEmpty) {
        throw Exception("La fecha es nula o está vacía");
      }
      final fecha = DateTime.tryParse(fechaStr);
      if (fecha == null) {
        throw Exception("Formato de fecha inválido: $fechaStr");
      }

      // Obtener y parsear la hora
      final horaStr = state.horaLimite.value;
      if (horaStr.isEmpty) {
        throw Exception("La hora es nula o está vacía");
      }
      final horaParts = horaStr.split(':');
      if (horaParts.length != 2) {
        throw Exception("Formato de hora inválido: $horaStr");
      }
      final hora = int.tryParse(horaParts[0]) ?? 0;
      final minuto = int.tryParse(horaParts[1]) ?? 0;

      // Combinar fecha y hora en un objeto DateTime
      return DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora,
        minuto,
      );
    } catch (e) {
      return null; // Retorna null si hay un error
    }
  }

  // 2. NUEVO MÉTODO: Limpiar formulario (usado al entrar en modo Creación)
  void clearForm() {
    resetStateForm();
  }

// En activity_form_notifier.dart (Línea 150)

Future<void> onFormUpdate(int subjectId, String nombreMateria, int activityId) async {
    if (state.isPosting) return;

    _touchEveryField();

    final fechaHoraConcatenada = _getFechaHoraConcatenada();
    if (fechaHoraConcatenada == null) {
      throw Exception("onFormUpdate Error: Fecha u hora inválida.");
    }

    // 🔴 LÓGICA DE PUNTAJE OPCIONAL: Si el campo está vacío, usa 100.
    final int puntajeToSend = state.puntaje.value.isEmpty
        ? 100
        // Si no está vacío, asume que es un número válido (por el tryParse de onPuntajeChanged)
        : int.tryParse(state.puntaje.value) ?? 100;
        
    // 🔴 ELIMINAR ESTO: Ya no se valida que puntajeInt no sea null
    // final puntajeInt = int.tryParse(state.puntaje.value);
    // if (puntajeInt == null) {
    //   throw Exception("onFormUpdate Error: Puntaje inválido.");
    // }

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    try {
      if (updateActivityCallback != null) {
        // Llamar al callback de actualización (AHORA CON 6 ARGUMENTOS)
        await updateActivityCallback!(
          activityId,
          state.nombre.value,
          state.descripcion.value,
          fechaHoraConcatenada,
          puntajeToSend, // <--- Usamos el valor calculado (100 por defecto o el ingresado)
          subjectId,     // <--- MateriaId/SubjectId
        );
        
        state = state.copyWith(isFormPosted: true);
      } else {
        throw Exception("updateActivityCallback no está definido en el provider");
      }

    } catch (e) {
      // ...
    } finally {
      // ...
    }
}

// En activity_form_notifier.dart

Future<void> onFormSubmit(int subjectId, String nombreMateria) async {
    if (state.isPosting) return;

    _touchEveryField();

    final fechaHoraConcatenada = _getFechaHoraConcatenada();
    if (fechaHoraConcatenada == null) {
      throw Exception("onFormSubmit Error: Fecha u hora inválida.");
    }

    // Lógica de Puntaje: 100 por defecto si está vacío
    final int puntajeToSend = state.puntaje.value.isEmpty
        ? 100
        : int.tryParse(state.puntaje.value) ?? 100;

    // Si la validación de Formz falla (por nombre, descripción, fecha, etc.), salimos
    if (!state.isValid) return; 

    state = state.copyWith(isPosting: true);

    final activityLike = {
      "nombreActividad": state.nombre.value,
      "descripcion": state.descripcion.value,
      "fechaLimite": fechaHoraConcatenada.toIso8601String(),
      "puntaje": puntajeToSend,
      "materiaId": subjectId
    };

    try {
      // 🎯 VERIFICACIÓN CRÍTICA: Aquí se llama a ActivityNotifier.createdActivity
      if (activityCallback == null) {
          throw Exception("Activity creation callback (activityCallback) is null");
      }
      
      await activityCallback!(activityLike); // ⬅️ ESTA ES LA LÍNEA QUE CREA LA ACTIVIDAD

      // Si la llamada al backend fue exitosa, marcamos como enviado
      state = state.copyWith(isFormPosted: true); 

    } catch (e) {
      debugPrint("Error al intentar crear actividad: $e");
      // Es importante relanzar el error para que la interfaz sepa que falló
      throw Exception("Error al crear actividad: $e");
    } finally {
      state = state.copyWith(isPosting: false);
    }
}

_touchEveryField() {
    final nombre = GenericInput.dirty(state.nombre.value);
    final descripcion = GenericInput.dirty(state.descripcion.value);
    final fechaLimite = GenericInput.dirty(state.fechaLimite.value);
    final horaLimite = GenericInput.dirty(state.horaLimite.value);
    final puntaje = GenericInput.dirty(state.puntaje.value); // Se mantiene para marcar como 'dirty'

    state = state.copyWith(
        isFormPosted: true,
        nombre: nombre,
        descripcion: descripcion,
        fechaLimite: fechaLimite,
        horaLimite: horaLimite,
        puntaje: puntaje,
        isValid: Formz.validate(
            [nombre, descripcion, fechaLimite, horaLimite] // <--- SE ELIMINA 'puntaje' DE LA VALIDACIÓN
        ));
}

  void resetStateForm() {
    nombreController.clear();
    descripcionController.clear();
    fechaController.clear();
    horaController.clear();
    puntajeController.clear();
    state = ActivityFormState();
    debugPrint("Formulario reseteado: $state");
  }

  onAnswerChanged(String answer) {
    state = state.copyWith(answer: answer);
    debugPrint("CONTENIDO DEL CAMPO");
    debugPrint(state.answer);
  }

  onHasSubmission() async {
    state = state.copyWith(existsAnswer: true);
  }

  onSendSubmission(int activityId) async {
    bool submissionSent =
        await sendSubmissionCallback(activityId, state.answer);
    if (submissionSent) {
      dropAnswer();
    }
  }

  onSendSubmissionOffline(int activityId) async {
    bool submissionSent =
        await sendSubmissionOfflineCallback(activityId, state.answer);
    if (submissionSent) {
      dropAnswer();
    }
  }

  dropAnswer() {
    state = state.copyWith(existsAnswer: false, answer: "");
  }

  onSubmissionGradeChanged(String grade) {
    final newGrade = GenericInput.dirty(grade);
    state =
        state.copyWith(newGrade: newGrade, isValid: Formz.validate([newGrade]));
  }

 Future<FormSubmitedResponseStatus> onSubmitGrade(int submissionId) async {
    FormSubmitedResponseStatus response = FormSubmitedResponseStatus();
    _touchFieldGrade();
    if (!state.isValid){
      response.isValid = false;
      return response;
    }
    state = state.copyWith(isPosting: true);

    response.isValid = true;
    final grade = state.newGrade.value;
    bool submitedGrade = await submissionGradingCallback(
        grade: int.parse(grade), submissionId: submissionId);
    response.success = submitedGrade;

    state = state.copyWith(isPosting: false);

    return response;
  }

  _touchFieldGrade() {
    final grade =
        GenericInput.dirty(state.newGrade.value);

    state = state.copyWith(
        isFormPosted: true, newGrade: grade, isValid: Formz.validate([grade]));
  }
}