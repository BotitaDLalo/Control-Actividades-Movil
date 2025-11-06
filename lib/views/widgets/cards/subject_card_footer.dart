import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/data/key_value_storage_service_providers.dart';

class CustomFooterContainer extends ConsumerWidget {
  final int? groupId;
  final int subjectId;
  final String subjectName;
  final String description;
  final String accessCode;
  const CustomFooterContainer(
      {super.key,
      this.groupId,
      required this.subjectId,
      required this.subjectName,
      required this.accessCode,
      required this.description});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: () async {
                final data = Subject(
                    groupId: groupId,
                    materiaId: subjectId,
                    nombreMateria: subjectName,
                    codigoAcceso: accessCode,
                    descripcion: description);
                if (role == cn.getRoleTeacherName) {
                  teacherSubjectOptions(data);
                } else if (role == cn.getRoleStudentName) {
                  studentSubjectOptions(data);
                }
              },
              icon: const Icon(Icons.assignment)),
          // const SizedBox(
          //   width: 60,
          // ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.people_alt)),
          // const SizedBox(
          //   width: 60,
          // ),
          // IconButton(
          //     onPressed: () {}, icon: const Icon(Icons.star_border_rounded)),
        ],
      ),
    );
  }
}
