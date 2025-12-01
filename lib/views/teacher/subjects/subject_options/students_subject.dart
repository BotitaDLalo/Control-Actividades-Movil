import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/teacher/groups_subjects/students_groups_subjects.dart';
import 'package:flutter/material.dart';

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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar estudiante'),
          content: Text('¿Estás seguro de que deseas eliminar a $name $lastName $lastName2 de esta materia?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!context.mounted) return;

                final subjectNotifier =
                    ref.read(studentsSubjectProvider.notifier);

                await subjectNotifier.removeStudentFromSubject(
                  subjectId: widget.id,
                  studentId: studentId,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    }

    if (lsStudents.isEmpty && _searchTerm.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.school_outlined,
              size: 200,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Padding(
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
      );
    } else if (lsStudents.isNotEmpty && filteredStudents.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron estudiantes con esa búsqueda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
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
        Expanded(
          child: StudentsGroupsSubjects(
            lsStudents: filteredStudents,
            studentOptionsFunction: showStudentOptions,
          ),
        ),
      ],
    );
  }
}
