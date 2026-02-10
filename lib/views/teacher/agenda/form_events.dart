import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/agenda/form_event_provider.dart';
import 'package:aprende_mas/views/teacher/agenda/button_event_form.dart';
import 'package:aprende_mas/views/teacher/agenda/option_dropdown.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_text_form_field.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_time_form_field.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';

class FormEvents extends ConsumerStatefulWidget {
  const FormEvents({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormEventsState();
}

class _FormEventsState extends ConsumerState<FormEvents> {
  @override
  Widget build(BuildContext context) {
    final formCreateEvent = ref.watch(formEventProvider);
    final formCreatedEventNotifier = ref.read(formEventProvider.notifier);

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Column(children: [
          CustomTextFormField(
            enableLineBreak: true,
            capitalizeFirstLetter: true,
            label: 'Titulo',
            onChanged: formCreatedEventNotifier.onTitleChanged,
          ),
          const SizedBox(
            height: 0,
          ),
          CustomTextFormField(
            capitalizeFirstLetter: true,
            label: 'Descripcion',
            onChanged: formCreatedEventNotifier.onDescriptionChanged,
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            'Inicia',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              CustomTimeFormField(
                label: 'Fecha',
                isDateField: true,
                hint: 'Fecha',
                width: 150,
                onChanged: formCreatedEventNotifier.onStartDateChanged,
              ),
              const SizedBox(
                width: 20,
              ),
              CustomTimeFormField(
                label: 'Hora',
                isTimeField: true,
                hint: 'Hora',
                width: 150,
                onChanged: formCreatedEventNotifier.onStartTimeChanged,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Termina',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              CustomTimeFormField(
                label: 'Fecha',
                isDateField: true,
                hint: 'Fecha',
                width: 150,
                onChanged: formCreatedEventNotifier.onEndDatechanged,
              ),
              const SizedBox(
                width: 20,
              ),
              CustomTimeFormField(
                label: 'Hora',
                isTimeField: true,
                hint: 'Hora',
                width: 150,
                onChanged: formCreatedEventNotifier.onEndTimechanged,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          OptionDropdownForm(),
          const SizedBox(
            height: 30,
          ),
          ButtonEventForm(
            buttonName: 'Crear evento',
            onPressed: () async {
              final currentState = ref.read(formEventProvider);
              if (currentState.isPosting || currentState.isFormPosted) {
                return;
              }
              WarningConfirmationDialog.show(
                context,
                message: 'Esta seguro de que desea crear este evento?',
                onConfirmPressed: () async {
                  try {
                    print("Formulario enviado");
                    await formCreatedEventNotifier.onFormSubmit();

                    final isPosted = ref.read(formEventProvider).isFormPosted;
                    if (isPosted) {
                      print("Formulario posteado exitosamente");
                      SuccessDialog.show(
                        context,
                        message: 'Evento creado exitosamente',
                        onOkPressed: () {
                          Navigator.of(context).pop();
                        },
                      );
                    } else {
                      print("El formulario no fue posteado");
                      ErrorDialog.show(
                        context,
                        message: 'No se pudo crear el evento. Por favor, intente de nuevo.',
                      );
                    }
                  } catch (e) {
                    print("Error al crear el evento: $e");
                    ErrorDialog.show(
                      context,
                      message: 'Error al crear el evento: $e',
                    );
                  }
                },
                onCancelPressed: () {},
              );
            },
          )
        ]),
      ),
    );
  }
}
