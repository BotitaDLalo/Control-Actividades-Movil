import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
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

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            '¿Deseas eliminar el alumno?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          content: ListTile(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
              iconSize: 30,
            ),
            title: Text(username),
            subtitle: Text("$name $lastName $lastName2"),
          ),
          contentPadding: const EdgeInsets.all(10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar solo el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // 3. IMPLEMENTACIÓN DE LA LÓGICA

                // Usar el notifier ya leído
                final success = await groupNotifier.removeStudentFromGroup(
                  groupId: widget.id,
                  studentId: studentId,
                );

                if (context.mounted) {
                  Navigator.pop(context); // Cerrar el diálogo
                  // Cerrar el ModalBottomSheet después de la eliminación
                  Navigator.pop(context);

                  // Mostrar diálogo de éxito
                  SuccessDialog.show(
                    context,
                    message: 'Alumno eliminado correctamente',
                  );
                }
              },
              child: const Text('Eliminar'),
            )
          ],
        ),
      );
    }

    if (lsStudents.isEmpty && _searchTerm.isEmpty) {
      // Caso 1: La lista inicial está vacía y no hay búsqueda activa
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/studentcap1.svg',
              height: 200,
              width: 200,
              color: Colors.black,
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
      );
    } else if (lsStudents.isNotEmpty && filteredStudents.isEmpty) {
      // Caso 2: Hay estudiantes, pero la búsqueda no encontró coincidencias
      return const Center(
        child: Text(
          'No se encontraron estudiantes con esa búsqueda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Caso 3: Mostrar la lista (filtrada o completa)
    return Column(
      children: [
        // 3. CAMPO DE BÚSQUEDA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: '  Buscar estudiantes por nombre o usuario',
              prefixIconConstraints: BoxConstraints(maxWidth: 24, maxHeight: 24),
              prefixIcon: SizedBox(width: 20, height: 20, child: SvgPicture.asset('assets/icons/buscar.svg', colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn))),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
        
        // 4. LISTA DE ESTUDIANTES (usa la lista filtrada)
        Expanded(
          child: StudentsGroupsSubjects(
            lsStudents: filteredStudents, // <-- Lista filtrada
            studentOptionsFunction: showStudentOptions,
          ),
        ),
      ],
    );
  }
}