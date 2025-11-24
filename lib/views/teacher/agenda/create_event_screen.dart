import 'package:aprende_mas/views/teacher/agenda/form_events.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key,});

  @override
  Widget build(BuildContext context) {
      //  debugPrint('CreateActivitiesScreen: subjectId: $subjectId, nombreMateria: $nombreMateria');
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBarHome(
          title: 'Crear evento',
          showSettings: false,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: FormEvents()
              ),
            ],
          ),
        ),
      ),
    );
  }
}

