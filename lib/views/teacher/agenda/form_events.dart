// import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/agenda/form_event_provider.dart';
import 'package:aprende_mas/views/teacher/agenda/button_event_form.dart';
import 'package:aprende_mas/views/teacher/agenda/option_dropdown.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_text_form_field.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_time_form_field.dart';

class FormEvents extends ConsumerStatefulWidget {
  const FormEvents({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormEventsState();
}

class _FormEventsState extends ConsumerState<FormEvents> {

  // @override
  //   void initState() {
  //     super.initState();
  //     final refreshKey = StateProvider<bool>((ref) => false);
  //     // Escuchar el estado del formulario para actualizar la lista y navegar
  //     ref.listen(formEventProvider, (previous, next) {
  //       if (next.isFormPosted) {
  //         ref.read(refreshKey.notifier).state = true; // Actualiza el estado
  //       }
  //     });
  //   }
    
  @override
  Widget build(BuildContext context) {
    final formCreateEvent = ref.watch(formEventProvider);
    final formCreatedEventNotifier = ref.read(formEventProvider.notifier);

    @override
    void initState() {
      super.initState();
      final refreshKey = StateProvider<bool>((ref) => false);
      // Escuchar el estado del formulario para actualizar la lista y navegar
      ref.listen(formEventProvider, (previous, next) {
        if (next.isFormPosted) {
          ref.read(refreshKey.notifier).state = true; // Actualiza el estado
        }
      });
    }

    void goRouterPop() {
      context.pop();
    }

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
            label: 'Descripción',
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
              // Verifica si no está enviando ya el formulario
              if (!ref.read(formEventProvider).isPosting) {
                try {
                  print("Formulario enviado");
                  await formCreatedEventNotifier.onFormSubmit();

                  if (formCreateEvent.isFormPosted) {
                    print("Formulario posteado exitosamente");
                    goRouterPop(); // Regresar después de éxito
                  } else {
                    print("El formulario no fue posteado");
                  }
                } catch (e) {
                  // Captura cualquier error en la creación del evento
                  print("Error al crear el evento: $e");
                }
              }
              goRouterPop();
            },
          )
        ]),
      ),
    );
  }
}
