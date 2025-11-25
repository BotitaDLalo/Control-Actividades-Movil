import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';

class StudentsSubject extends ConsumerStatefulWidget {
  final int id;
  const StudentsSubject({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentsSubjectState();
}

class _StudentsSubjectState extends ConsumerState<StudentsSubject> {
  @override
  Widget build(BuildContext context) {
    // La lista de estudiantes es vigilada (watched) para actualizar la UI si cambia.
    final lsStudents = ref.watch(studentsSubjectProvider).lsStudentsSubject;

    void showStudentOptions(
        // 🎉 AÑADIDO: El ID del alumno es crucial para la eliminación.
        {required int studentId, 
        required String username,
        required String name,
        required String lastName,
        required String lastName2}) { // Corregido: tipo String para lastName2
      
      // 1. Cerramos el ModalBottomSheet antes de mostrar el AlertDialog.
      // Opcional, pero ayuda a simplificar la navegación después.
      //Navigator.pop(context); 

        showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    // ... (Title, Content, etc.)
                    actions: [
                        TextButton(
                            onPressed: () {
                                Navigator.pop(context);
                            },
                            child: const Text('Cancelar')
                        ),
                        TextButton(
                            onPressed: () async {
                                // ❌ La eliminación del bottom sheet antes de este punto causó la eliminación del estado.
                                
                                // 🎯 CORRECCIÓN CLAVE: Verificar si el widget sigue activo
                                if (!context.mounted) return; 

                                // Leer el Notifier de forma segura
                                final subjectNotifier = ref.read(studentsSubjectProvider.notifier);

                                // Realizar la operación asíncrona (API call)
                                await subjectNotifier.removeStudentFromSubject(
                                    subjectId: widget.id, 
                                    studentId: studentId, 
                                );

                                // 🎯 Verificar de nuevo antes de usar context/Navigator después del await
                                if (context.mounted) {
                                    // Cerrar el diálogo de confirmación
                                    Navigator.pop(context);
                                }
                            },
                            child: const Text('Eliminar')
                        )
                    ],
                ),
            );
    }

    return StudentsGroupsSubjects(
      lsStudents: lsStudents,
      // NOTA: Recuerda que StudentsGroupsSubjects debe pasar studentId a showStudentOptions
      studentOptionsFunction: showStudentOptions, 
    );
  }
}