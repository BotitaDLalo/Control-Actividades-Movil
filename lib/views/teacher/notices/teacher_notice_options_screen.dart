import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/future_notices_provider.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/widgets/buttons/floating_action_button_custom.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeacherNoticeOptionsScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int subjectId;
  const TeacherNoticeOptionsScreen(
      {super.key, this.groupId = 0, this.subjectId = 0});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoticeOptionsScreenState();
}

class _NoticeOptionsScreenState
    extends ConsumerState<TeacherNoticeOptionsScreen> {
  NoticeModel notice = NoticeModel();

  @override
  void initState() {
    if (widget.groupId != 0) {
      notice = notice.copyWith(groupId: widget.groupId);
    } else if (widget.subjectId != 0) {
      notice = notice.copyWith(subjectId: widget.subjectId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final futureNoticesls = ref.watch(futureNoticesProvider(notice));
    void requestAgain() {
      void _ = ref.refresh(futureNoticesProvider(notice));
    }

    ref.listen(
      noticesFormProvider,
      (previous, next) {
        if ((next.isFormPosted || next.isDeleted) && !next.isPosting) {
          requestAgain();
        }
      },
    );

    return Scaffold(
        floatingActionButton: FloatingActionButtonCustom(
          voidCallback: () {
            context.push('/teacher-create-notice', extra: notice);
          },
          icon: Icons.add,
        ),
        body: futureNoticesls.when(
          data: (data) => data.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 180,
                          child: SvgPicture.asset(
                            'assets/icons/new_notice.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Aquí podrás publicar anuncios,\nrecordatorios o enlaces\nimportantes para tus estudiantes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                      children: data
                          .map(
                            (e) => Column(
                              children: [
                                NoticeBody(
                                    optionsIsVisible: true,
                                    noticeId: e.noticeId ?? 0,
                                    teacherName: e.teacherFullName ?? "",
                                    createdDate: e.createdDate.toString(),
                                    title: e.title,
                                    content: e.description),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.02)
                              ],
                            ),
                          )
                          .toList()),
                ),
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
  }
}
