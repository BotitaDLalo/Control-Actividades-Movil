import 'package:aprende_mas/views/widgets/cards/subject_card.dart';
import '../../../config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';

class SubjectsWithoutGroupsContainer extends ConsumerStatefulWidget {
  const SubjectsWithoutGroupsContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubjectsWithoutGroupsState();
}

class _SubjectsWithoutGroupsState
    extends ConsumerState<SubjectsWithoutGroupsContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    return ListView.builder(
      itemCount: subjects.lsSubjects.length,
      itemBuilder: (context, index) {
        final subject = subjects.lsSubjects[index];
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
