class FileInfo {
  final String nombre;
  final String ruta;

  FileInfo({required this.nombre, required this.ruta});
}

class TeacherStudentSubmissionGradingModel {
  final int submissionId;
  final String userName;
  final String fullName;
  final String answer;
  final List<String> links;
  final List<FileInfo> files;
  final int grade;
  final int score;
  final String submissionDate;

  TeacherStudentSubmissionGradingModel({
    required this.submissionId,
    required this.userName,
    required this.fullName,
    required this.answer,
    this.links = const [],
    this.files = const [],
    required this.grade,
    required this.score,
    required this.submissionDate,
  });
}
