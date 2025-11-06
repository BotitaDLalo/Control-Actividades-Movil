import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';

class StudentsGroup extends ConsumerStatefulWidget {
  final int id;
  const StudentsGroup({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentsGroupState();
}

class _StudentsGroupState extends ConsumerState<StudentsGroup> {
  @override
  Widget build(BuildContext context) {
    final lsStudents = ref.watch(studentsGroupProvider).lsStudentsGroup;

    void showStudentOptions(
        {required String username,
        required String name,
        required String lastName,
        required lastName2}) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_remove_alt_1),
                  title: const Text('Eliminar alumno'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          '¿Deseas eliminar el alumno?',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
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
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () {
                                //TODO: Eliminar el alumno de la materia
                              },
                              child: const Text('Eliminar'))
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return StudentsGroupsSubjects(
      lsStudents: lsStudents,
      studentOptionsFunction: showStudentOptions,
    );
  }
}
