import 'package:flutter/material.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/form_activities.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/button_ai.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/form_activities.dart'; // Asegúrate de importar tu formulario
import 'package:aprende_mas/models/models.dart'; // Asegúrate de importar el modelo Activity
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/providers/activity/activty_form_provider.dart';


class CreateActivitiesScreen extends StatefulWidget {
  final int subjectId;
  final String nombreMateria;
  final Activity? activity;

  const CreateActivitiesScreen({
    super.key,
    required this.subjectId,
    required this.nombreMateria,
    this.activity,
  });

  @override
  State<CreateActivitiesScreen> createState() => _CreateActivitiesScreenState();
}

class _CreateActivitiesScreenState extends State<CreateActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final subjectColor = getSubjectColor(widget.subjectId);

    // Usar Consumer para obtener los controladores del provider
    return Consumer(
      builder: (context, ref, _) {
        final activityNotifier = ref.read(activityFormProvider.notifier);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.activity == null ? 'Crear Actividad' : 'Editar Actividad'),
            leading: IconButton(
              icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: subjectColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                FormActivities(
                  subjectId: widget.subjectId,
                  nombreMateria: widget.nombreMateria,
                  activity: widget.activity,
                ),
              ],
            ),
          ),
          floatingActionButton: ButtonAI(
            tituloController: activityNotifier.nombreController,
            descripcionController: activityNotifier.descripcionController,
            onSuggestionUsed: () {
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
