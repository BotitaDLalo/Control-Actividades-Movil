class FileSubmission {
  final String nombre;
  final String ruta;

  FileSubmission({required this.nombre, required this.ruta});
}

class StudentSubmission {
  final int submissionId;
  final int studentId;
  final String userName;
  final String names;
  final String lastName;
  final String lastName2;
  final String submissionDate;
  final String answer;
  final List<String> links;
  final List<FileSubmission> files;
  int grade;

  StudentSubmission({
      required this.submissionId,
      required this.studentId,
      required this.userName,
      required this.names,
      required this.lastName,
      required this.lastName2,
      required this.submissionDate,
      required this.answer,
      this.links = const [],
      this.files = const [],
      required this.grade});
}
