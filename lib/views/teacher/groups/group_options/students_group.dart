import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';
import 'package:flutter/material.dart'; // Importante para TextField

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
      
      // Cerrar el ModalBottomSheet antes de mostrar el diálogo
      Navigator.pop(context);

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
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // 3. IMPLEMENTACIÓN DE LA LÓGICA
                
                // Acceder al Notifier de Grupos
                final groupNotifier = ref.read(studentsGroupProvider.notifier);

                // Llamar a la función de eliminación
                final success = await groupNotifier.removeStudentFromGroup(
                  groupId: widget.id,
                  studentId: studentId,
                );

                if (context.mounted) {
                  Navigator.pop(context); // Cerrar el diálogo
                }

                if (success) {
                  // Opcional: Feedback visual
                  // print("Alumno eliminado del grupo correctamente");
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
          children: const [
            Icon(
              Icons.group_outlined, // Icono adaptado para grupos
              size: 200,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Padding(
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
            decoration: const InputDecoration(
              labelText: 'Buscar estudiantes por nombre o usuario',
              prefixIcon: Icon(Icons.search),
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