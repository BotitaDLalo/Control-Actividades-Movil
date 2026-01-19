import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:flutter/material.dart'; // Importante para TextField
import 'package:flutter_svg/flutter_svg.dart';

class StudentsGroup extends ConsumerStatefulWidget {
  final int id; // Este es el GroupId
  const StudentsGroup({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentsGroupState();
}

class _StudentsGroupState extends ConsumerState<StudentsGroup> {
  // 1. ESTADO DE BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // Escucha los cambios en el campo de texto y actualiza el estado
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
    // 1. Escuchar la lista de estudiantes del grupo (Lista completa)
    final lsStudents = ref.watch(studentsGroupProvider).lsStudentsGroup;

    // 2. LÓGICA DE FILTRADO LOCAL
    final filteredStudents = lsStudents.where((student) {
      final searchLower = _searchTerm.toLowerCase();
      
      // Construimos el nombre completo para la búsqueda (nombre + apellidos)
      final fullName = 
          '${student.name} ${student.lastName} ${student.lastName2}'.toLowerCase();
      
      final usernameLower = student.username.toLowerCase();

      // Devolvemos true si el término de búsqueda coincide con el nombre completo O el nombre de usuario
      return fullName.contains(searchLower) || usernameLower.contains(searchLower);
    }).toList();


    void showStudentOptions({
      // 2. AÑADIDO: Recibir el ID del alumno
      required int studentId,
      required String username,
      required String name,
      required String lastName,
      required String lastName2,
    }) {

      // Leer el notifier ANTES de la operación async para evitar el error de ref disposed
      final groupNotifier = ref.read(studentsGroupProvider.notifier);

      // Mostrar diálogo de confirmación antes de eliminar
      WarningConfirmationDialog.show(
        context,
        message: '¿Está seguro de que desea eliminar a este alumno del grupo?',
        onConfirmPressed: () async {
          try {
            // 3. IMPLEMENTACIÓN DE LA LÓGICA

            // Usar el notifier ya leído
            final success = await groupNotifier.removeStudentFromGroup(
              groupId: widget.id,
              studentId: studentId,
            );

            if (success) {
              // Mostrar mensaje de éxito
              SuccessDialog.show(
                context,
                message: 'Alumno eliminado del grupo exitosamente',
                onOkPressed: () {
                  // No es necesario hacer nada, el diálogo se cierra automáticamente
                },
              );
            } else {
              // Mostrar mensaje de error
              ErrorDialog.show(
                context,
                message: 'No se pudo eliminar al alumno del grupo. Por favor, intente de nuevo.',
              );
            }
          } catch (e) {
            // Captura cualquier error en la eliminación del alumno
            print("Error al eliminar al alumno del grupo: $e");
            // Mostrar mensaje de error
            ErrorDialog.show(
              context,
              message: 'Error al eliminar al alumno del grupo: $e',
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
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '  Buscar estudiantes por nombre o usuario',
                prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
                prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn))),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),

        // Contenido
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
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Aquí se mostrarán los estudiantes que agregues al grupo.",
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
                      lsStudents: filteredStudents, // <-- Lista filtrada
                      studentOptionsFunction: showStudentOptions,
                    ),
        ),
      ],
    );
  }
}