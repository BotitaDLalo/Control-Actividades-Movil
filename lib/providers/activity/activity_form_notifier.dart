import 'dart:io';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/views/widgets/inputs/generic_input.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:file_picker/file_picker.dart';

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
  final Function(int, String, List<String>)? sendSubmissionWithLinksCallback;
  final Function(int, String, List<String>, List<String>)? sendSubmissionWithFilesAndLinksCallback;
  final Function(int, String, List<String>)? sendSubmissionWithFilesCallback;
  final Function(int, String) sendSubmissionOfflineCallback;
  final Function({required int submissionId, required int grade})
      submissionGradingCallback;
  final Future<String> Function(PlatformFile file, int activityId, int studentId)? uploadFileCallback; // Nuevo: para subir archivos
  
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
       this.updateActivityCallback,
       this.sendSubmissionWithLinksCallback,
       this.sendSubmissionWithFilesCallback,
       this.sendSubmissionWithFilesAndLinksCallback,
       this.uploadFileCallback,
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
              final fechaStr = state.fechaLimite.value.trim();
              if (fechaStr.isEmpty) {
                throw Exception("La fecha es nula o está vacía");
              }
              final fechaParts = fechaStr.split('-');
              if (fechaParts.length != 3) {
                throw Exception("Formato de fecha inválido: $fechaStr");
              }
              final day = int.tryParse(fechaParts[0]);
              final month = int.tryParse(fechaParts[1]);
              final year = int.tryParse(fechaParts[2]);
              if (day == null || month == null || year == null) {
                throw Exception("Formato de fecha inválido: $fechaStr");
              }
              final fecha = DateTime(year, month, day);

            // 🎯 LÓGICA ACTUALIZADA: Obtener y manejar la hora
            final horaStr = state.horaLimite.value;
            
            // 1. Si la hora está vacía, usamos 23:59 (11:59 PM)
            int hora = 23; // Default: 23 horas
            int minuto = 59; // Default: 59 minutos

            if (horaStr.isNotEmpty) {
                final horaParts = horaStr.split(':');
                if (horaParts.length != 2) {
                  throw Exception("Formato de hora inválido: $horaStr");
                }
                hora = int.tryParse(horaParts[0]) ?? 0;
                minuto = int.tryParse(horaParts[1]) ?? 0;
            }
            // Si horaStr está vacía, se usan los valores por defecto (23 y 59).

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

  Future<void> onFormUpdate(int subjectId, String nombreMateria, int activityId) async {
      if (state.isPosting) return;

      _touchEveryField();

      final fechaHoraConcatenada = _getFechaHoraConcatenada();
      if (fechaHoraConcatenada == null) {
        throw Exception("onFormUpdate Error: Fecha u hora inválida.");
      }

      final int puntajeToSend = state.puntaje.value.isEmpty
          ? 100
          // Si no está vacío, asume que es un número válido (por el tryParse de onPuntajeChanged)
          : int.tryParse(state.puntaje.value) ?? 100;
          
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
      final horaLimite = GenericInput.dirty(state.horaLimite.value); // Se mantiene como dirty
      final puntaje = GenericInput.dirty(state.puntaje.value);

      state = state.copyWith(
          isFormPosted: true,
          nombre: nombre,
          descripcion: descripcion,
          fechaLimite: fechaLimite,
          horaLimite: horaLimite, // Lo marcamos como tocado
          puntaje: puntaje,
          isValid: Formz.validate(
              // 🎯 CAMBIO: Se remueve horaLimite y puntaje de la validación
              [nombre, descripcion, fechaLimite] 
          ));
  }

    void resetStateForm() {
      nombreController.clear();
      descripcionController.clear();
      fechaController.clear();
      horaController.clear();
      puntajeController.clear();
      answerController.clear();
      state = ActivityFormState();
      debugPrint("Formulario reseteado: $state");
    }

    /// Calcular si hay contenido en alguno de los campos (texto, enlaces o archivos)
    bool _hasContent() {
      return state.answer.isNotEmpty || state.links.isNotEmpty || state.files.isNotEmpty;
    }
    onAnswerChanged(String answer) {
      state = state.copyWith(answer: answer, existsAnswer: _hasContent());
      debugPrint("CONTENIDO DEL CAMPO");
      debugPrint(state.answer);
    }

    onHasSubmission() async {
      state = state.copyWith(existsAnswer: _hasContent());
    }

     Future<bool> onSendSubmission(int activityId) async {
        bool submissionSent = false;
        
        // Obtener studentId del storage
        final storageService = KeyValueStorageServiceImpl();
        final studentId = await storageService.getId();
        
        // Si hay archivos, primero los subimos y obtenemos URLs
        List<String> fileUrls = [];
        if (state.files.isNotEmpty && uploadFileCallback != null) {
          for (var file in state.files) {
            try {
              final url = await uploadFileCallback!(file, activityId, studentId);
              fileUrls.add(url);
              debugPrint("✅ Archivo subido: $url");
            } catch (e) {
              debugPrint("❌ Error subiendo archivo ${file.name}: $e");
            }
          }
        }
        
        // Determinar qué callback usar y evaluar el resultado
        try {
          if (fileUrls.isNotEmpty && sendSubmissionWithFilesAndLinksCallback != null) {
            final result = await sendSubmissionWithFilesAndLinksCallback!(activityId, state.answer, fileUrls, state.links);
            submissionSent = result == true;
          } else if (fileUrls.isNotEmpty && sendSubmissionWithFilesCallback != null) {
            final result = await sendSubmissionWithFilesCallback!(activityId, state.answer, fileUrls);
            submissionSent = result == true;
          } else if (sendSubmissionWithLinksCallback != null) {
            final result = await sendSubmissionWithLinksCallback!(activityId, state.answer, state.links);
            submissionSent = result == true;
          } else if (sendSubmissionCallback != null) {
            final result = await sendSubmissionCallback(activityId, state.answer);
            submissionSent = result == true;
          }
        } catch (e) {
          debugPrint("❌ Error en callbacks de envío: $e");
          submissionSent = false;
        }
        
        debugPrint("📤 Resultado de envío: submissionSent = $submissionSent");
        
        if (submissionSent) {
          dropAnswer();
        }
        
        return submissionSent;
      }

    onSendSubmissionOffline(int activityId) async {
       bool submissionSent =
           await sendSubmissionOfflineCallback(activityId, state.answer);
       if (submissionSent) {
         dropAnswer();
       }
    }

    dropAnswer() {
      state = state.copyWith(existsAnswer: false, answer: "", files: [], links: []);
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

    void onFilesChanged(List<PlatformFile> files) {
      state = state.copyWith(files: files, existsAnswer: _hasContent());
    }

    void onLinksChanged(List<String> links) {
      state = state.copyWith(links: links, existsAnswer: _hasContent());
    }
}
