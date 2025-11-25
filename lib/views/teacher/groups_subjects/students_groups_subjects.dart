import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:aprende_mas/providers/providers.dart';

class StudentsGroupsSubjects extends ConsumerStatefulWidget {
  final List<StudentGroupSubject> lsStudents;
  final VoidCallback? voidCallback;
  final void Function(
      {required int studentId,
      required String username,
      required String name,
      required String lastName,
      required String lastName2})? studentOptionsFunction;

  const StudentsGroupsSubjects(
      {super.key,
      required this.lsStudents,
      this.voidCallback,
      this.studentOptionsFunction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentsGroupsSubjectsState();
}

class _StudentsGroupsSubjectsState
    extends ConsumerState<StudentsGroupsSubjects> {
  @override
  Widget build(BuildContext context) {
    final lsStudents = widget.lsStudents;

    // return SingleChildScrollView(
    //   child: Column(
    //     children: [
    //       SizedBox(
    //         height: MediaQuery.of(context).size.height,
    //         width: 360,
    //         child: ListView.builder(
    //           itemCount: lsStudents.length,
    //           itemBuilder: (context, index) {
    //             return ElementTile(
    //                 icon: Icons.person,
    //                 iconColor: Colors.white,
    //                 iconSize: 28,
    //                 title: lsStudents[index].username,
    //                 subtitle:
    //                     "${lsStudents[index].lastName} ${lsStudents[index].lastName2} ${lsStudents[index].name}",
    //                 onTapFunction: () {},
    //                 trailing: '');
    //           },
    //         ),
    //       )
    //     ],
    //   ),
    // );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: lsStudents.length,
                  itemBuilder: (context, index) {
                    final studentId = lsStudents[index].alumnoId;
                    final username = lsStudents[index].username;
                    final lastname = lsStudents[index].lastName;
                    final lastname2 = lsStudents[index].lastName2;
                    final name = lsStudents[index].name;
                    return ElementTile(
                      icon: Icons.person,
                      iconColor: Colors.white,
                      iconSize: 32,
                      title: username,
                      subtitle: "$lastname $lastname2 $name",
                      trailingIcon: Icons.more_vert,
                      trailingColor: Colors.black,
                      trailingVoidCallback: () {
                        widget.studentOptionsFunction!(
                            studentId: studentId,
                            username: username,
                            lastName: lastname,
                            lastName2: lastname2,
                            name: name);
                      },
                    );
                  })),
          const SizedBox(
            height: 40,
          )
        ]),
      ),
    );
  }
}
