class TeacherStudentSubmissionGradingModel {
  final int submissionId;
  final String userName;
  final String fullName;
  final String answer;
  final List<String> links;
  final List<String> files;
  final int grade;
  final int score;

  TeacherStudentSubmissionGradingModel({
    required this.submissionId,
    required this.userName,
    required this.fullName,
    required this.answer,
    this.links = const [],
    this.files = const [],
    required this.grade,
    required this.score,
  });
}
