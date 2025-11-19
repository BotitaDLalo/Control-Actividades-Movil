import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/cards/subject_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectScroll extends ConsumerWidget {
  final int? groupId;
  final List<Subject>? materias;
  const SubjectScroll({super.key, required this.materias, this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var materia in materias ?? [])
            SubjectCard(
              groupId: groupId,
              subjectId: materia.materiaId,
              nombreMateria: materia.nombreMateria,
              accessCode: materia.codigoAcceso,
              description: materia.descripcion ?? "",
              actividades: materia.actividades,
              widthFactor: 0.60,
              heightFactor: 0.18,
            )
        ],
      ),
    );
  }
}
