import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/student/notices/student_notice_options_screen.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:aprende_mas/views/student/student.dart';

final itemTappedProvider = StateProvider<int>((ref) => 1);

class StudentSubjectOptionsScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final int? groupId;
  final String subjectName;
  final String description;
  final String accessCode;
  const StudentSubjectOptionsScreen({
    super.key,
    this.groupId,
    required this.subjectId,
    required this.subjectName,
    required this.accessCode,
    required this.description,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentSubjectOptionsScreenState();
}

class _StudentSubjectOptionsScreenState
    extends ConsumerState<StudentSubjectOptionsScreen> {
  void onOptionSelected(int index) {
    ref.read(itemTappedProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final itemTapped = ref.watch(itemTappedProvider);

    List<GroupSubjectWidgetOption> lsSubjectWidgetOptions = [
      GroupSubjectWidgetOption(
          optionId: 1,
          isVisible: true,
          optionText: 'Avisos',
          widgetOption: StudentNoticeOptionsScreen(
            groupId: widget.groupId ?? 0,
            subjectId: widget.subjectId,
          )),
      GroupSubjectWidgetOption(
        optionId: 2,
        isVisible: true,
        optionText: 'Actividades',
        widgetOption: ActivityOptionScreen(
            buttonCreateIsVisible: false,
            subjectId: widget.subjectId,
            subjectName: widget.subjectName),
      ),
    ];

    List<GroupSubjectWidgetOption> lsSubjectOptions =
        GroupSubjectWidgetOption.getlsGroupSubjectOptions(
            lsSubjectWidgetOptions);

    Widget getWidget(int index) {
      GroupSubjectWidgetOption option = lsSubjectWidgetOptions.firstWhere(
        (element) => element.optionId == index,
      );
      return option.widgetOption!;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            ContainerNameGroupSubjects(
              name: widget.subjectName,
              color: getSubjectColor(widget.subjectId),
              accessCode: widget.accessCode,
            ),
            StudentSubjectOptions(
                lsSubjectOptions: lsSubjectOptions,
                onOptionSelected: onOptionSelected,
                selectedOptionIndex: ref.watch(itemTappedProvider),
                subjectId: widget.subjectId),
            Expanded(
              child:
                  getWidget(itemTapped), // Muestra el contenido correspondiente
            ),
          ],
        ),
      ),
    );
  }
}
