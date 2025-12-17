import 'package:aprende_mas/models/models.dart';

class JoinClass {
  final Group? group;
  final Subject? subject;
  final bool isGroup;

  JoinClass(
      {required this.group, required this.subject, required this.isGroup});

  static JoinClass resJsonToEntity(Map<String, dynamic> map) => JoinClass(
      group: map['Grupo'] != null ? Group.mapToEntity(map['Grupo']) : null,
      subject:
          map['Materia'] != null ? Subject.mapToEntity(map['Materia']) : null,
      isGroup: map['EsGrupo'] as bool? ?? false); // Handle nullable bool
}
