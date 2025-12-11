import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/views/teacher/agenda/form_update_event.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateEventScreen extends StatelessWidget {
  final Event event;

  const UpdateEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
      //  debugPrint('CreateActivitiesScreen: subjectId: $subjectId, nombreMateria: $nombreMateria');
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBarHome(title: 'Editar Evento', showSettings: false, leading: IconButton(icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 30, height: 30, color: Colors.white), onPressed: () => Navigator.pop(context))),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: FormUpdateEvent(event),
          ),
        ),
      ),
    );
  }
}

