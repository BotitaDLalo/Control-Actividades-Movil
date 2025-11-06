import 'package:aprende_mas/views/teacher/agenda/form_events.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:flutter/material.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key,});

  @override
  Widget build(BuildContext context) {
      //  debugPrint('CreateActivitiesScreen: subjectId: $subjectId, nombreMateria: $nombreMateria');
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  HeaderTile(
                    svg: 'assets/icons/agregar-tarea.svg', 
                    titulo: 'Crear Evento',
                    // colorUno: Color(0xff536cf6),
                    // colorDos: Color(0xff66A9F2),
                  ),
                  Positioned(
                    left: 10,
                    top: 40,
                    child: ButtonClose(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: FormEvents()
              ),
            ],
          ),
        ),
      ),
    );
  }
}

