class StudentGroupSubject {
  final int alumnoId;
  final String username;
  final String name;
  final String email;
  final String lastName;
  final String lastName2;

  StudentGroupSubject(
      {required this.alumnoId,
      required this.username,
      required this.name,
      required this.email,
      required this.lastName,
      required this.lastName2});

  static List<StudentGroupSubject> studentGroupSubjectJsonToEntity(
      List<Map<String, dynamic>> studentGroupJson) {
    return studentGroupJson.map((json) {
      return StudentGroupSubject(
        alumnoId: json['AlumnoId'] as int,
        email: json['Email'] as String,
        username: json['UserName'] as String,
        name: json['Nombre'] as String,
        lastName: json['ApellidoPaterno'] as String,
        lastName2: json['ApellidoMaterno'] as String,
      );
    }).toList();
  }
}
