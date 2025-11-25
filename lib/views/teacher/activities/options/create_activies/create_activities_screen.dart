import 'package:flutter/material.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/form_activities.dart'; // Asegúrate de importar tu formulario
import 'package:aprende_mas/models/models.dart'; // Asegúrate de importar el modelo Activity

class CreateActivitiesScreen extends StatelessWidget {
  final int subjectId;
  final String nombreMateria;
  // 1. AGREGAR ESTA VARIABLE
  final Activity? activity; 

  const CreateActivitiesScreen({
    super.key,
    required this.subjectId,
    required this.nombreMateria,
    // 2. AGREGAR AL CONSTRUCTOR
    this.activity, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Cambiamos el título dinámicamente dependiendo si es editar o crear
        title: Text(activity == null ? 'Crear Actividad' : 'Editar Actividad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Aquí llamas a tu formulario
            FormActivities(
              subjectId: subjectId,
              nombreMateria: nombreMateria,
              // 3. PASAR LA ACTIVIDAD AL FORMULARIO
              activity: activity, 
            ),
          ],
        ),
      ),
    );
  }
}