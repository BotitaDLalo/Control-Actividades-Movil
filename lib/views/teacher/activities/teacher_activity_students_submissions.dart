import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/activities_body/container_information_activity.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeacherActivityStudentsSubmissions extends ConsumerStatefulWidget {
  final Activity activity;
  const TeacherActivityStudentsSubmissions({super.key, required this.activity});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeacherActivityStudentsSubmissionsState();
}

class _TeacherActivityStudentsSubmissionsState
    extends ConsumerState<TeacherActivityStudentsSubmissions> {
  @override
  Widget build(BuildContext context) {
    final activityId = widget.activity.activityId;
    final activityStudentsSubmissions =
        ref.watch(activityStudentsSubmissionsProvider(activityId!));

    void refreshScreen() {
      void _ = ref.refresh(activityStudentsSubmissionsProvider(activityId));
    }

    ref.listen(
      activityProvider,
      (previous, next) {
        if (previous?.grade != next.grade) {
          refreshScreen();
        }
      },
    );

    return activityStudentsSubmissions.when(
        loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        error: (error, stack) => const Scaffold(
              body: Text('Hubo un error'),
            ),
        data: (data) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              forceMaterialTransparency: true,
              leading: IconButton(
                icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                '',
                style: TextStyle(color: Colors.black),
              ),
            ),
            backgroundColor: Colors.white,
            body: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ContainerInformationActivity(
                              icon: Icons.mail_rounded,
                              title: 'Entregados',
                              content: data.totalSubmissions.toString()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ContainerInformationActivity(
                            icon: Icons.grade_rounded,
                            title: 'Puntaje',
                            content: data.score.toString(),
                            onTapFunction: () {
                              //TODO: MODIFICAR PUNTAJE AQUI
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Entregas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 2));
                      refreshScreen();
                    },
                    child: SizedBox(
                      height: double.infinity,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: data.lsStudentsSubmissions.map((e) {
                              final fullName =
                                  "${e.lastName} ${e.lastName2} ${e.names}";
                              return ElementTile(
                                onTapFunction: () {
                                  ref
                                      .read(activityProvider.notifier)
                                      .setSubmissionGrade(e.grade);
                                  TeacherStudentSubmissionGradingModel
                                      extraData =
                                  TeacherStudentSubmissionGradingModel(
                                      submissionId: e.submissionId,
                                      grade: e.grade,
                                      score: data.score,
                                      userName: e.userName,
                                      fullName: fullName,
                                      answer: e.answer,
                                      links: e.links,
                                      files: e.files.map((f) => FileInfo(nombre: f.nombre, ruta: f.ruta)).toList(),
                                      submissionDate: e.submissionDate,);

                                  context.push(
                                      '/teacher-student-submission-grading',
                                      extra: extraData);
                                },
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/user2.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                                iconColor: Colors.white,
                                iconSize: 32,
                                title: fullName,
                                subtitle: e.userName,
                                trailingWidget: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/edit2.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
