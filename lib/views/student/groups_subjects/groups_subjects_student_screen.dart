import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/student/student.dart';
import 'package:aprende_mas/views/users/groups_subjects/groups_subjects_screen.dart';
import 'package:aprende_mas/views/widgets/buttons/floating_action_button_custom.dart';
import 'package:aprende_mas/views/widgets/structure/modal_bottom_sheet_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupsSubjectsStudentScreen extends ConsumerStatefulWidget {
  const GroupsSubjectsStudentScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupsSubjectsTeacherScreenState();
}

class _GroupsSubjectsTeacherScreenState
    extends ConsumerState<GroupsSubjectsStudentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lsOptions = [
      ListTile(
        leading: SvgPicture.asset('assets/icons/unirseClase.svg', width: 24, height: 24),
        title: const Text('Unirse a una clase'),
        onTap: () {
          Navigator.pop(context);
          context.push('/student-join-group-subject');
        },
      ),
    ];

    return GroupsSubjectsScreen(
      voidCallback: () => modalBottomSheetCustom(context, lsOptions),
    );
  }
}
