import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentsSubject extends ConsumerStatefulWidget {
  final int id;
  const StudentsSubject({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentsSubjectState();
}

class _StudentsSubjectState extends ConsumerState<StudentsSubject> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lsStudents = ref.watch(studentsSubjectProvider).lsStudentsSubject;
    final subjectColor = getSubjectColor(widget.id);

    final filteredStudents = lsStudents.where((student) {
      final searchLower = _searchTerm.toLowerCase();
      final fullName =
          '${student.name} ${student.lastName} ${student.lastName2}'.toLowerCase();
      final usernameLower = student.username.toLowerCase();
      return fullName.contains(searchLower) || usernameLower.contains(searchLower);
    }).toList();

    void showStudentOptions({
      required int studentId,
      required String username,
      required String name,
      required String lastName,
      required String lastName2,
    }) {
      // Leer el notifier ANTES de la operación async para evitar el error de ref disposed
      final subjectNotifier = ref.read(studentsSubjectProvider.notifier);

      // Mostrar diálogo de confirmación antes de eliminar
      WarningConfirmationDialog.show(
        context,
        message: '¿Está seguro de que desea eliminar a este alumno de la materia?',
        onConfirmPressed: () async {
          try {
            if (!context.mounted) return;

            // Usar el notifier ya leído
            final result = await subjectNotifier.removeStudentFromSubject(
              subjectId: widget.id,
              studentId: studentId,
            );

            if (result['success']) {
              // Mostrar mensaje de éxito
              SuccessDialog.show(
                context,
                message: 'Alumno eliminado de la materia exitosamente',
                onOkPressed: () {
                  // No es necesario hacer nada, el diálogo se cierra automáticamente
                },
              );
            } else {
              // Mostrar mensaje de error
              ErrorDialog.show(
                context,
                message: result['message'],
              );
            }
          } catch (e) {
            // Captura cualquier error en la eliminación del alumno
            print("Error al eliminar al alumno de la materia: $e");
            // Mostrar mensaje de error
            ErrorDialog.show(
              context,
              message: 'Error al eliminar al alumno de la materia: $e',
            );
          }
        },
        onCancelPressed: () {
          // No hacer nada, solo cerrar el diálogo
        },
      );
    }

    return Column(
      children: [
        // Mostrar barra de búsqueda solo si hay estudiantes
        if (lsStudents.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '  Buscar estudiantes por nombre o usuario',
                prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
                prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn))),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: subjectColor, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
        Expanded(
          child: lsStudents.isEmpty && _searchTerm.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/studentcap1.svg',
                        height: 200,
                        width: 200,
                        colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Aquí se mostrarán los estudiantes que agregues a la materia.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : lsStudents.isNotEmpty && filteredStudents.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron estudiantes con esa búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : StudentsGroupsSubjects(
                      lsStudents: filteredStudents,
                      studentOptionsFunction: showStudentOptions,
                      displayColor: subjectColor,
                    ),
        ),
      ],
    );
  }
}