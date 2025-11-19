import 'package:aprende_mas/views/widgets/cards/subject_card_activities.dart';
import 'package:aprende_mas/views/widgets/cards/subject_card_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/data/key_value_storage_service_providers.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/packages.dart';

import '../../../models/models.dart';
import 'subject_card_footer.dart';

class SubjectCard extends ConsumerWidget {
  final int? groupId;
  final int subjectId;
  final String nombreMateria;
  final String description;
  final String accessCode;
  final List<Activity>? actividades;

  const SubjectCard({
    super.key,
    this.groupId,
    required this.subjectId,
    required this.nombreMateria,
    required this.description,
    required this.accessCode,
    required this.actividades,
  });

  // Genera un degradado agradable determinístico a partir del subjectId
  LinearGradient _makeGradient(int id) {
    final hue = (id * 47) % 360;
    final c1 = HSLColor.fromAHSL(1, hue.toDouble(), 0.62, 0.48).toColor();
    final c2 = HSLColor.fromAHSL(1, (hue + 25) % 360, 0.70, 0.40).toColor();
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = _makeGradient(subjectId);

    // Mantengo las medidas responsivas similares al original
    final width = MediaQuery.of(context).size.width * 0.70;
    final height = MediaQuery.of(context).size.height * 0.24;

    final cn = ref.watch(catalogNamesProvider);
    final role = ref.watch(roleFutureProvider).maybeWhen(
          data: (data) => data,
          orElse: () => "",
        );

    void teacherSubjectOptions(Subject data) {
      context.push('/teacher-subject-options', extra: data);
    }

    void studentSubjectOptions(Subject data) {
      context.push('/student-subject-options', extra: data);
    }

    
    return GestureDetector(
      onTap: () {
        final data = Subject(
          groupId: groupId,
          materiaId: subjectId,
          nombreMateria: nombreMateria,
          codigoAcceso: accessCode,
          descripcion: description);
      if (role == cn.getRoleTeacherName) {
        teacherSubjectOptions(data);
      } else if (role == cn.getRoleStudentName) {
        studentSubjectOptions(data);
      }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.0),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                // Mantengo tu CustomHeaderContainer (lógica intacta)
                // Lo envolvemos en un container con fondo semitransparente para lectura
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  
                  
                  
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    // quitar color o poner transparente
                    color: Colors.transparent,
                    child: Text(
                      nombreMateria,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
      
                ),
      
                /*
                // Contenedor central para las actividades: uso Expanded para que footer se quede fijo abajo
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    // fondo ligeramente translúcido para dar contraste con el header/footer
                    color: Colors.white.withOpacity(0.06),
                    child: actividades == null || actividades!.isEmpty
                        ? Center(
                            child: Text(
                              'Sin actividades',
                              style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            ),
                          )
                        : ListView.builder(
                            // replico tu limitación a 3 elementos si existían antes
                            itemCount: actividades!.take(3).length,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final actividad = actividades![index];
                              // Mantengo el widget que antes usabas para renderizar actividades
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CustomActivitiesContainer(
                                  actividades: actividad,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                */
      
                // Divider sutil
                Container(height: 1, color: Colors.white.withOpacity(0.12)),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
