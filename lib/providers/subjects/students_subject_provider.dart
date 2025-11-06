import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/subjects/students_subject_state.dart';
import 'package:aprende_mas/providers/subjects/students_subject_state_notifier.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_respository_impl.dart';

final studentsSubjectProvider = StateNotifierProvider<
    StudentsSubjectStateNotifier, StudentsSubjectState>(
  (ref) {
    final subjectRepository = SubjectsRespositoryImpl();

    return StudentsSubjectStateNotifier(subjectsRepository: subjectRepository);
  },
);
