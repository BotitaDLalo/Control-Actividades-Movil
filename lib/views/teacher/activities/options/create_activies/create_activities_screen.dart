import 'package:flutter/material.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/form_activities.dart';
import 'package:aprende_mas/views/teacher/activities/options/create_activies/button_ai.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
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
    // Ejemplo: se asume que los controladores se obtienen de alguna forma
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    // Si tienes otra forma de obtenerlos (por ejemplo, desde un provider), reemplaza esto

    final subjectColor = getSubjectColor(subjectId);
    return Scaffold(
      appBar: AppBar(
        title: Text(activity == null ? 'Crear Actividad' : 'Editar Actividad'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: subjectColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FormActivities(
              subjectId: subjectId,
              nombreMateria: nombreMateria,
              activity: activity,
            ),
          ],
        ),
      ),
      floatingActionButton: ButtonAI(
        tituloController: nombreController,
        descripcionController: descripcionController,
      ),
    );
  }
}
