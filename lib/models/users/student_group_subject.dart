class StudentGroupSubject {
  final int alumnoId;
  final String username;
  final String name;
  final String email;
  final String lastName;
  final String lastName2;
  final int? grupoId;
  final int alumnoMateriaId;

  StudentGroupSubject(
      {required this.alumnoId,
      required this.username,
      required this.name,
      required this.email,
      required this.lastName,
      required this.lastName2, 
      this.grupoId,
      required this.alumnoMateriaId});

static List<StudentGroupSubject> studentGroupSubjectJsonToEntity(
    List<Map<String, dynamic>> studentGroupJson) {
  return studentGroupJson.map((json) {

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final alumnoIdValue =
        json['AlumnoId'] ??
        json['alumnoId'] ??
        json['Id'] ??
        json['id'] ??
        0;

    final alumnoMateriaIdValue =
        json['AlumnoMateriaId'] ??
        json['alumnoMateriaId'] ??
        json['alumno_materia_id'] ??
        0;

    return StudentGroupSubject(
      alumnoId: safeInt(alumnoIdValue),
      alumnoMateriaId: safeInt(alumnoMateriaIdValue), // ✅ CLAVE
      email: json['Email'] as String,
      username: json['UserName'] as String,
      name: json['Nombre'] as String,
      lastName: json['ApellidoPaterno'] as String,
      lastName2: json['ApellidoMaterno'] as String,
      grupoId: safeInt(json['GrupoId']),
    );
  }).toList();
}

}
