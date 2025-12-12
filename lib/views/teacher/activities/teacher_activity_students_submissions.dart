import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/activities_body/container_information_activity.dart';

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
                icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 30, height: 30, color: Colors.white),
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
                                          answer: e.answer);

                                  context.push(
                                      '/teacher-student-submission-grading',
                                      extra: extraData);
                                },
                                icon: Icons.person,
                                iconColor: Colors.white,
                                iconSize: 32,
                                title: e.userName,
                                subtitle:
                                    "${e.lastName} ${e.lastName2} ${e.names}",
                                trailingString: e.grade == -1
                                    ? 'Sin calificar'
                                    : "${e.grade}/${data.score}",
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
