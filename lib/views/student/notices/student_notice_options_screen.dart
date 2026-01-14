import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/activities_body/notice/notice_body/notice_body.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final subjectColor = getSubjectColor(widget.subjectId);

    final futureNoticesls = ref.watch(futureNoticesProvider(notice));

    void requestAgain() {
      void _ = ref.refresh(futureNoticesProvider(notice));
    }

    return Scaffold(
      body: futureNoticesls.when(
        data: (data) {
          if (data.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                requestAgain();
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 150),
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 200,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Sin Avisos, \nespera a que tu profesor te envíe un Aviso",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              requestAgain();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/calendar2.svg',
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                            colorFilter:
                                ColorFilter.mode(subjectColor, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes avisos en esta materia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
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
                                    height: MediaQuery.of(context).size.height *
                                        0.02)
                              ],
                            ),
                          )
                          .toList()),
            ),
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
