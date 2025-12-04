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

// --- CÓDIGO CORREGIDO EN StudentGroupSubject ---

static List<StudentGroupSubject> studentGroupSubjectJsonToEntity(
    List<Map<String, dynamic>> studentGroupJson) {
  return studentGroupJson.map((json) {
    // Definimos una función de ayuda para asegurar que los ints se casteen de forma segura
    int safeInt(dynamic value) {
      // Si el valor es nulo o no es un int, devuelve 0 (o el valor seguro por defecto)
      if (value == null || value is! int) {
        return 0;
      }
      return value;
    }

    return StudentGroupSubject(
      // Aplicamos el chequeo seguro a todos los int
      alumnoId: safeInt(json['AlumnoId']), // ⬅️ CORRECCIÓN
      email: json['Email'] as String,
      username: json['UserName'] as String,
      name: json['Nombre'] as String,
      lastName: json['ApellidoPaterno'] as String,
      lastName2: json['ApellidoMaterno'] as String,
      // Aunque este ya estaba bien, lo dejamos como estaba:
      grupoId: safeInt(json['grupoId']), 
    );
  }).toList();
}
}
