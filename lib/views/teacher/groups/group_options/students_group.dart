import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';

class StudentsGroup extends ConsumerStatefulWidget {
  final int id; // Este es el GroupId
  const StudentsGroup({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentsGroupState();
}

class _StudentsGroupState extends ConsumerState<StudentsGroup> {
  @override
  Widget build(BuildContext context) {
    // 1. Escuchar la lista de estudiantes del grupo
    final lsStudents = ref.watch(studentsGroupProvider).lsStudentsGroup;

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

                // Llamar a la función de eliminación (asumiendo que crearás 'removeStudentFromGroup')
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

    return StudentsGroupsSubjects(
      lsStudents: lsStudents,
      studentOptionsFunction: showStudentOptions,
    );
  }
}