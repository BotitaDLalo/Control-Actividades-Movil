import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/providers/subjects/students_subject_provider.dart';
import 'package:aprende_mas/views/teacher/activities/options/options.dart';
import 'package:aprende_mas/views/teacher/subjects/subject_options/students_subject.dart';
import 'package:aprende_mas/views/teacher/subjects/subject_options/teacher_subject_options.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';


final _itemTappedProvider = StateProvider<int>((ref) => 1);
class TeacherSubjectOptionsScreen extends ConsumerStatefulWidget {
  final int? groupId;
  final int subjectId;
  final String subjectName;
  final String description;
  final String codeAccess;

  const TeacherSubjectOptionsScreen(
      {super.key,
      this.groupId,
      required this.subjectId,
      required this.subjectName,
      required this.description,
      required this.codeAccess});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActividadesScreenState();
}

class _ActividadesScreenState
    extends ConsumerState<TeacherSubjectOptionsScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(studentsSubjectProvider.notifier)
        .getStudentsSubject(widget.groupId, widget.subjectId);
  }

  void onOptionSelected(int index) {
    ref.read(_itemTappedProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {

    final itemTapped = ref.watch(_itemTappedProvider);

    void clearScreen() {
      ref.read(addStudentMessageProvider.notifier).state = false;
      ref.read(studentsSubjectProvider.notifier).clearSubjectTeacherOptionsLs();
    }

    List<GroupSubjectWidgetOption> lsSubjectWidgetOptions = [
      GroupSubjectWidgetOption(
          optionId: 1,
          isVisible: widget.groupId == null ? true : false,
          optionText: 'Avisos',
          widgetOption: TeacherNoticeOptionsScreen(subjectId: widget.subjectId,)),
      GroupSubjectWidgetOption(
          optionId: 2,
          isVisible: true,
          optionText: 'Actividades',
          widgetOption: ActivityOptionScreen(
            buttonCreateIsVisible: true,
            subjectId: widget.subjectId,
            subjectName: widget.subjectName,
          )),
      GroupSubjectWidgetOption(
          optionId: 3,
          isVisible: true,
          optionText: 'Alumnos asignados',
          widgetOption: StudentsSubject(id: widget.subjectId)),
      GroupSubjectWidgetOption(
          optionId: 4,
          isVisible: widget.groupId == null ? true : false,
          optionText: 'Asignar alumnos',
          widgetOption: StudentsSubjectAssignment(
              groupId: widget.groupId, subjectId: widget.subjectId))
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        clearScreen();
      },
      child: Scaffold(
        // removemos la AppBar global para que el header personalizado se muestre
        // dentro del body y podamos controlar mejor su apariencia
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Header personalizado
              ContainerNameGroupSubjects(
                name: widget.subjectName,
                accessCode: widget.codeAccess,
                color: AppTheme.mainColor,
              ),
              // opciones y contenido
              TeacherSubjectOptions(
                lsSubjectOptions: lsSubjectOptions,
                onOptionSelected: onOptionSelected,
                selectedOptionIndex: ref.watch(_itemTappedProvider),
              ),
              Expanded(
                child: getWidget(itemTapped),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
