import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activity_provider.dart';
import 'package:aprende_mas/providers/activity/activty_form_provider.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_time_form_field.dart';
import 'package:aprende_mas/models/models.dart'; 
import 'package:intl/intl.dart'; 
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';

class FormActivities extends ConsumerStatefulWidget {
  final int subjectId;
  final String nombreMateria;
  final Activity? activity; // <--- 1. Recibimos la actividad opcionalmente

  const FormActivities({
    super.key,
    required this.subjectId,
    required this.nombreMateria,
    this.activity, // <--- Agregar al constructor
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormActivitiesState();
}

class _FormActivitiesState extends ConsumerState<FormActivities> {
  
    @override
    void initState() {
      super.initState();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(activityFormProvider.notifier);
        
        if (widget.activity != null) {
          final act = widget.activity!;
          
          // Rellenar campos de texto simples
          notifier.nombreController.text = act.nombreActividad;
          notifier.descripcionController.text = act.descripcion;
          notifier.puntajeController.text = act.puntaje.toString();

          // ---------------------------------------------------------
          // CORRECCIÓN DE FECHAS
          // ---------------------------------------------------------
          DateTime dateObject;
          
          try {
            // 1. Definimos el formato en que viene tu fecha (dd-MM-yyyy HH:mm:ss)
            final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
            
            // 2. Convertimos el String a DateTime
            dateObject = inputFormatter.parse(act.fechaLimite.toString());
          } catch (e) {
            // Fallback: Si falla (por ejemplo si viene en formato ISO), intentamos el parseo estándar
            dateObject = DateTime.tryParse(act.fechaLimite.toString()) ?? DateTime.now();
          }

          // 3. Ahora sí podemos formatear el DateTime seguro
          final datePart = DateFormat('dd-MM-yyyy').format(dateObject);
          final timePart = DateFormat('HH:mm').format(dateObject);

          notifier.fechaController.text = datePart;
          notifier.horaController.text = timePart;
          // ---------------------------------------------------------

          // Actualizar el estado del formulario
          notifier.onNombreChanged(act.nombreActividad);
          notifier.onDescripcionChanged(act.descripcion);
          notifier.onPuntajeChanged(act.puntaje.toString());
          notifier.onFechaLimiteChanged(datePart);
          notifier.onHoraLimiteChanged(timePart);
          
        } else {
          notifier.clearForm();
        }
      });
    }

  @override
  Widget build(BuildContext context) {
    final activityForm = ref.watch(activityFormProvider);
    final activityNotifier = ref.read(activityFormProvider.notifier);
    final subjectColor = getSubjectColor(widget.subjectId);

    void goRouterPop() {
      context.pop();
    }

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.nombreMateria,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Completa la información para asignar actividades o proyectos a tus estudiantes',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500, 
                color: Color(0xFF283043), 
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: activityNotifier.nombreController,
              onChanged: activityNotifier.onNombreChanged,
              decoration: InputDecoration(
                labelText: 'Nombre Actividad',
                errorText: activityForm.isFormPosted ? activityForm.nombre.errorMessage : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: subjectColor, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: activityNotifier.descripcionController,
              onChanged: activityNotifier.onDescripcionChanged,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Descripción',
                errorText: activityForm.isFormPosted ? activityForm.descripcion.errorMessage : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: subjectColor, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Opcional, mejora la alineación
            children: [
              // 1. Campo de FECHA: Envuelto en Expanded y SIN la propiedad 'width'
              Expanded(
                child: CustomTimeFormField(
                    controller: activityNotifier.fechaController,
                    label: 'Fecha Límite',
                    hint: 'Fecha',
                    isDateField: true,
                    errorMessage: activityForm.isFormPosted
                        ? activityForm.fechaLimite.errorMessage
                        : null,
                    onChanged: ref.read(activityFormProvider.notifier).onFechaLimiteChanged
                ),
              ),
              
              const SizedBox(width: 15), // Separación entre campos
              
              // 2. Campo de HORA: Envuelto en Expanded y SIN la propiedad 'width'
              Expanded(
                child: CustomTimeFormField(
                    controller: activityNotifier.horaController,
                    label: 'Hora de Entrega',
                    isTimeField: true,
                    hint: 'Hora (Opcional)',
                    errorMessage: activityForm.isFormPosted
                        ? activityForm.horaLimite.errorMessage
                        : null,
                    onChanged: ref.read(activityFormProvider.notifier).onHoraLimiteChanged
                ),
              ),
            ],
          ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: activityNotifier.puntajeController,
              onChanged: activityNotifier.onPuntajeChanged,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Puntaje (Opcional)',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: subjectColor, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 30, // Separación antes del botón
            ),
            SizedBox(
              height: 56,
              // 3. Botón Dinámico (Crear o Actualizar)
              child: CustomRoundedButton(
                  //  CAMBIO 1: Usamos 'text' en lugar de 'buttonName'
                  text: widget.activity == null
                      ? 'Crear actividad'
                      : 'Actualizar actividad',

                  // CAMBIO 2: Añadimos estilos (ejemplo basado en tu otro archivo)
                  backgroundColor: subjectColor,
                  textColor: Colors.white,
                  borderRadius: 10,
                  
                  onPressed: () async {
                    // Si ya se está enviando, salimos inmediatamente.
                    if (ref.read(activityFormProvider).isPosting) return;

                    // El notifier que contiene la lógica de envío
                    final activityNotifier = ref.read(activityFormProvider.notifier);
                    
                    try {
                      // Si estamos en modo EDICIÓN
                      if (widget.activity != null) {
                          await activityNotifier.onFormUpdate(
                             widget.subjectId, 
                             widget.nombreMateria,
                             widget.activity!.activityId! 
                          );
                          
                          // Mostrar diálogo de éxito
                          if (mounted) {
                            SuccessDialog.show(
                              context,
                              message: 'Actividad actualizada correctamente',
                              onOkPressed: () {
                                ref.invalidate(activitiesBySubjectProvider(widget.subjectId));
                                goRouterPop();
                              },
                            );
                          }
                      } 
                      // Si estamos en modo CREACIÓN
                      else {
                        await activityNotifier.onFormSubmit(
                              widget.subjectId, widget.nombreMateria);
                        
                        // Mostrar diálogo de éxito
                        if (mounted) {
                          SuccessDialog.show(
                            context,
                            message: 'Actividad creada correctamente',
                            onOkPressed: () {
                              ref.invalidate(activitiesBySubjectProvider(widget.subjectId));
                              goRouterPop();
                            },
                          );
                        }
                      }
                    } catch (e) {
                      // Mostrar diálogo de error
                      if (mounted) {
                        ErrorDialog.show(
                          context,
                          message: 'Ocurrió un error: ${e.toString()}',
                        );
                      }
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}