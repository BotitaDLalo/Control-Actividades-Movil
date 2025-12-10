import 'package:aprende_mas/config/utils/general_utils.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/providers/agenda/event_provider.dart';
import 'package:aprende_mas/providers/agenda/form_update_event_provider.dart';
import 'package:aprende_mas/views/teacher/agenda/button_event_form.dart';
import 'package:aprende_mas/views/teacher/agenda/update_dropdown.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_input_field.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_time_form_field.dart';

class FormUpdateEvent extends ConsumerWidget {
  final Event event;

  const FormUpdateEvent(this.event, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formUpdateEvent = ref.watch(formUpdateEventProvider(event));
    final formUpdateEventNotifier =
        ref.read(formUpdateEventProvider(event).notifier);

    void goRouterPop() {
      context.go("/teacher-home");
    }

    ref.listen(formUpdateEventProvider(event), (previous, next) {
      if (next.isFormPosted && !next.isPosting) {
        goRouterPop();
        ref.read(eventProvider.notifier).getEvents();
      }
    });



    return Form(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Card de información básica
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_document, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Información del Evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    CustomInputField(
                      enableLineBreak: true,
                      capitalizeFirstLetter: true,
                      label: 'Título',
                      initialValue: formUpdateEvent.title.value,
                      onChanged: formUpdateEventNotifier.onUpdateTitleChanged,
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      capitalizeFirstLetter: true,
                      label: 'Descripción',
                      initialValue: formUpdateEvent.description.value,
                      onChanged: formUpdateEventNotifier.onUpdateDescriptionChanged,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card de fecha de inicio
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha de Inicio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth > 400 ? 150 : double.infinity,
                              child: CustomTimeFormField(
                                label: 'Fecha',
                                isDateField: true,
                                hint: 'Fecha',
                                width: constraints.maxWidth > 400 ? 150 : double.infinity,
                                initialValue: formatOnlyDate(event.startDate),
                                onChanged: formUpdateEventNotifier.onUpdateStartDateChanged,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth > 400 ? 150 : double.infinity,
                              child: CustomTimeFormField(
                                label: 'Hora',
                                isTimeField: true,
                                hint: 'Hora',
                                width: constraints.maxWidth > 400 ? 150 : double.infinity,
                                initialValue: formatOnlyTime(event.startDate),
                                onChanged: formUpdateEventNotifier.onUpdateStartTimeChanged,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card de fecha de fin
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stop, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha de Fin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth > 400 ? 150 : double.infinity,
                              child: CustomTimeFormField(
                                label: 'Fecha',
                                isDateField: true,
                                hint: 'Fecha',
                                width: constraints.maxWidth > 400 ? 150 : double.infinity,
                                initialValue: formatOnlyDate(event.endDate),
                                onChanged: formUpdateEventNotifier.onUpdateEndDateChanged,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth > 400 ? 150 : double.infinity,
                              child: CustomTimeFormField(
                                label: 'Hora',
                                isTimeField: true,
                                hint: 'Hora',
                                width: constraints.maxWidth > 400 ? 150 : double.infinity,
                                initialValue: formatOnlyTime(event.endDate),
                                onChanged: formUpdateEventNotifier.onUpdateEndTimeChanged,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card de destinatario
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Destinatario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    UpdateDropdownForm(
                      event: event,
                      isGroup: (event.groupIds != null &&
                          event.groupIds!.isNotEmpty), // Convertimos a bool
                      initialItemId: event.groupIds != null && event.groupIds!.isNotEmpty
                          ? event.groupIds!.first // Si hay grupo, toma el primer ID
                          : (event.subjectIds != null && event.subjectIds!.isNotEmpty
                              ? event.subjectIds!
                                  .first // Si no hay grupo, toma el primer ID de materia
                              : null), // Si no hay nada, envía null
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de actualizar
            SizedBox(
              width: double.infinity,
              child: ButtonEventForm(
                buttonName: 'Actualizar Evento',
                onPressed: () async {
                  if (!ref.watch(formUpdateEventProvider(event)).isPosting) {
                    final success = await formUpdateEventNotifier.onUpdateFormSubmit(
                      event.eventId!,
                      event.teacherId,
                    );
                    if (success) {
                      goRouterPop();
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 80), // Espacio para los FABs
          ],
        ),
      ),
    );
  }
}
