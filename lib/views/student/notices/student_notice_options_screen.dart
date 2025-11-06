import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/activities_body/notice/notice_body/notice_body.dart';

import '../../../providers/notices/future_notices_provider.dart';

class StudentNoticeOptionsScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int subjectId;
  const StudentNoticeOptionsScreen(
      {super.key, this.groupId = 0, this.subjectId = 0});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentNoticeOptionsScreenState();
}

class _StudentNoticeOptionsScreenState
    extends ConsumerState<StudentNoticeOptionsScreen> {
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

    return Scaffold(
      body: futureNoticesls.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            requestAgain();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
                children: data
                    .map(
                      (e) => Column(
                        children: [
                          NoticeBody(
                              optionsIsVisible: false,
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
        ),
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
