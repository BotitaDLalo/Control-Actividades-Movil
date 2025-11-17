import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/groups/students_group_provider.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:aprende_mas/views/teacher/teacher.dart';

final _itemTappedProvider = StateProvider<int>((ref) => 1);
class GroupTeacherOptions extends ConsumerStatefulWidget {
  final int groupId;
  final String groupName;
  final String description;
  final String? accessCode;
  // final String colorCode;
  const GroupTeacherOptions({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.description,
    this.accessCode,
    // required this.colorCode
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupTeacherOptionsState();
}

class _GroupTeacherOptionsState extends ConsumerState<GroupTeacherOptions> {
  @override
  void initState() {
    super.initState();
    ref.read(studentsGroupProvider.notifier).getStudentsGroup(widget.groupId);
  }


  void onOptionSelected(int index) {
    ref.read(_itemTappedProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final itemTapped = ref.watch(_itemTappedProvider);

    void clearScreen() {
      ref.read(addStudentMessageProvider.notifier).state = false;
      ref.read(studentsGroupProvider.notifier).clearGroupTeacherOptionsLs();
    }

    List<GroupSubjectWidgetOption> lsGroupWidgetOptions = [
      GroupSubjectWidgetOption(
          optionId: 1,
          isVisible: true,
          optionText: 'Avisos',
          widgetOption: TeacherNoticeOptionsScreen(
            groupId: widget.groupId,
          )),
      GroupSubjectWidgetOption(
          optionId: 2,
          isVisible: true,
          optionText: 'Alumnos asignados',
          widgetOption: StudentsGroup(id: widget.groupId)),
      GroupSubjectWidgetOption(
          optionId: 3,
          isVisible: true,
          optionText: 'Asignar alumnos',
          widgetOption: StudentsGroupAssigment(id: widget.groupId)),
      GroupSubjectWidgetOption(
          optionId: 4,
          isVisible: true,
          optionText: 'Editar',
          widgetOption: FormUpdateGroup(
            id: widget.groupId,
            groupName: widget.groupName,
            description: widget.description,
            accesCode: widget.accessCode,
            // colorCode: widget.colorCode,
          ))
    ];

    List<GroupSubjectWidgetOption> lsGroupOptions =
        GroupSubjectWidgetOption.getlsGroupSubjectOptions(lsGroupWidgetOptions);

    Widget getWidget(int index) {
      GroupSubjectWidgetOption option = lsGroupWidgetOptions.firstWhere(
        (element) => element.optionId == index,
      );
      return option.widgetOption!;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        clearScreen();
      },
      child: Scaffold(
        appBar: const AppBarScreens(),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ContainerNameGroupSubjects(
              name: widget.groupName,
              accessCode: widget.accessCode,
              color: const Color(0xFF31D492),
            ),
            TeacherGroupOptions(
                lsGroupOptions: lsGroupOptions,
                onOptionSelected: onOptionSelected,
                selectedOptionIndex: ref.watch(_itemTappedProvider)),
            Expanded(
              child: getWidget(itemTapped),
            ),
          ],
        ),
      ),
    );
  }
}
