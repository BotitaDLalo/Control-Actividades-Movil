class StudentGroupSubject {
  final int alumnoId;
  final String username;
  final String name;
  final String email;
  final String lastName;
  final String lastName2;
  final int? grupoId;

  StudentGroupSubject(
      {required this.alumnoId,
      required this.username,
      required this.name,
      required this.email,
      required this.lastName,
      required this.lastName2, 
      this.grupoId});

static List<StudentGroupSubject> studentGroupSubjectJsonToEntity(
    List<Map<String, dynamic>> studentGroupJson) {
  return studentGroupJson.map((json) {
    
    int safeInt(dynamic value) {
      if (value == null || value is! int) {
        return 0;
      }
      return value;
    }
    final studentIdValue = 
        json['Id'] ?? 
        json['AlumnoId'] ?? 
        json['id'] ?? 
        json['alumnoId'] ?? 
        0; 

    return StudentGroupSubject(
      alumnoId: safeInt(studentIdValue), 
      
      email: json['Email'] as String,
      username: json['UserName'] as String,
      name: json['Nombre'] as String,
      lastName: json['ApellidoPaterno'] as String,
      lastName2: json['ApellidoMaterno'] as String,
      grupoId: safeInt(json['grupoId']),
    );
  }).toList();
}

}
