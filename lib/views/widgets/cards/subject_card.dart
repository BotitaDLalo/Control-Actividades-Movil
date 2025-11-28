import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/data/key_value_storage_service_providers.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';

class SubjectCard extends ConsumerWidget {
  final int? groupId;
  final int subjectId;
  final String nombreMateria;
  final String description;
  final String accessCode;
  final List<Activity>? actividades;
  final double widthFactor;
  final double heightFactor;

  const SubjectCard({
    super.key,
    this.groupId,
    required this.subjectId,
    required this.nombreMateria,
    required this.description,
    required this.accessCode,
    required this.actividades,
    this.widthFactor = 0.5,
    this.heightFactor = 0.15,
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

    // Ahora calculamos dimensiones en función del espacio disponible usando LayoutBuilder.
    // Si el padre no proporciona un ancho finito (por ejemplo, en una lista horizontal),
    // se usa MediaQuery como fallback.

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

    void _showDeleteConfirmation(BuildContext context, Subject subjectData) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar materia'),
          content: const Text('¿Estás seguro de que deseas eliminar esta materia? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await ref.read(subjectsProvider.notifier).deleteSubject(subjectData.materiaId!);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se eliminó la materia')),
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    }


    // Selección determinística de watermark (usa recursos existentes en assets/icons)
    const watermarkIcons = [
      //'assets/icons/grupo.svg',
      'assets/icons/book1.svg',
      //'assets/icons/school.svg',
    ];
    final watermark = watermarkIcons[subjectId % watermarkIcons.length];

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final width = availableWidth * widthFactor;
      final height = MediaQuery.of(context).size.height * heightFactor;

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
        margin: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 9.0),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Watermark grande en la esquina inferior derecha (no haga overflow)
                Positioned(
                  right: -00,
                  bottom: -00,
                  child: Opacity(
                    opacity: 0.12,
                    child: SvgPicture.asset(
                      watermark,
                      // Limitamos el tamaño para evitar overflow en tarjetas bajas
                      width: min(width * 0.8, height * 1.0),
                      height: min(width * 0.5, height * 1.0),
                      color: Colors.white,
                    ),
                  ),
                ),

                // Menú de opciones en la esquina superior derecha
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.white,
                    ),
                    onSelected: (value) {
                      final data = Subject(
                          groupId: groupId,
                          materiaId: subjectId,
                          nombreMateria: nombreMateria,
                          codigoAcceso: accessCode,
                          descripcion: description);
                      if (value == 'options') {
                        if (role == cn.getRoleTeacherName) {
                          teacherSubjectOptions(data);
                        } else if (role == cn.getRoleStudentName) {
                          studentSubjectOptions(data);
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, data);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'options',
                        child: Text('Opciones'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                ),

                // Contenido principal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título grande a la izquierda
                      Text(
                        nombreMateria,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      // Descripción pequeña
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      ),
                      const Spacer(),
                      // Row inferior: MORE y posible número de actividades
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*
                          Text(
                            'MORE',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600),
                          ),
                          */
                          if (actividades != null && actividades!.isNotEmpty)
                            Text(
                              '${actividades!.length} actividades',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}
