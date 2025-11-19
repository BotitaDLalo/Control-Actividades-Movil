import 'package:aprende_mas/views/widgets/cards/subject_card.dart';
import '../../../config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';

class SubjectsWithoutGroupsContainer extends ConsumerStatefulWidget {
  const SubjectsWithoutGroupsContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubjectsWithoutGroupsContainerState();
}

class _SubjectsWithoutGroupsContainerState
    extends ConsumerState<SubjectsWithoutGroupsContainer> {
  Color stringToColor(String hexColor) {
    Color colorCode = Color(int.parse("0xFF$hexColor"));
    return colorCode;
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).lsSubjects;
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SubjectCard(
            subjectId: subject.materiaId,
            nombreMateria: subject.nombreMateria,
            description: subject.descripcion ?? "",
            accessCode: subject.codigoAcceso ?? "",
            actividades: subject.actividades,
            widthFactor: 0.96,
            heightFactor: 0.14,
          ),
        );
      },
    );
  }
}
