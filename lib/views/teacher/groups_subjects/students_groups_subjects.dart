import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:aprende_mas/providers/providers.dart';

class StudentsGroupsSubjects extends ConsumerStatefulWidget {
  final List<StudentGroupSubject> lsStudents;
  final VoidCallback? voidCallback;
  final Color? displayColor;

  final void Function({
    // required int alumnoMateriaId,
    required int studentId,
    required String username,
    required String name,
    required String lastName,
    required String lastName2,
  })? studentOptionsFunction;



  const StudentsGroupsSubjects(
      {super.key,
      required this.lsStudents,
      this.voidCallback,
      this.studentOptionsFunction,
      this.displayColor});

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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: lsStudents.length,
                itemBuilder: (context, index) {
                  //final studentId = lsStudents[index].alumnoId;
                  final studentId = lsStudents[index].alumnoMateriaId;
                  final username = lsStudents[index].username;
                  final lastname = lsStudents[index].lastName;
                  final lastname2 = lsStudents[index].lastName2;
                  final name = lsStudents[index].name;

                  return ElementTile(
                    iconWidget: SvgPicture.asset(
                      'assets/icons/user2.svg',
                      width: 32,
                      height: 32,
                      colorFilter:
                          ColorFilter.mode(widget.displayColor ?? Colors.blue, BlendMode.srcIn),
                    ),
                    iconColor: Colors.white,
                    iconSize: 32,
                    title: "$name $lastname $lastname2",
                    subtitle: username,
                    trailingWidget: IconButton(
                      onPressed: () {
                        widget.studentOptionsFunction!(
                          studentId: studentId,
                          username: username,
                          lastName: lastname,
                          lastName2: lastname2,
                          name: name,
                        );
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.displayColor ?? Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/eliminar4.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
