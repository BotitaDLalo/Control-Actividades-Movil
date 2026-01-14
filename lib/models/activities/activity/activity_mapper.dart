import 'activity.dart';
import 'package:intl/intl.dart';
import 'package:aprende_mas/config/utils/general_utils.dart';

class ActivityMapper {
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  static List<Activity> fromMapList(List<Map<String, dynamic>> data) {
    return data.map((map) {
      return Activity(
          activityId: map['ActividadId'] as int,
          nombreActividad: map['NombreActividad'] as String,
          descripcion: map['DescripcionActividad'] as String,
          // tipoActividadId: map['TipoActividadId'] as int,
          fechaCreacion: formatDate(map['FechaCreacionActividad']),
          fechaLimite: formatDate(map['FechaLimiteActividad']),
          materiaId: map['MateriaId'] as int,
          puntaje: map['Puntaje'] as int);
    }).toList();
  }

  static Map<String, dynamic> toMap(Activity activity) {
    return {
      'actividadId': activity.activityId,
      'nombreActividad': activity.nombreActividad,
      'descripcionActividad': activity.descripcion,
      'tipoActividadId': activity.tipoActividadId,
      'fechaCreacionActividad': formatDate(activity.fechaCreacion!),
      'fechaLimiteActividad': formatDate(activity.fechaLimite),
      'materiaId': activity.materiaId,
      'puntaje': activity.puntaje
    };
  }

    static Activity jsonToEntity(Map<String, dynamic> json) {
  print("Datos json: $json");

  return Activity(
    activityId: json['ActivityId'] != null ? json['activityId'] as int : null,  // Se permite null
    nombreActividad: json['NombreActividad'] as String? ?? '',
    descripcion: json['Descripcion'] as String? ?? '',
    tipoActividadId: json['TipoActividadId'] != null ? json['TipoActividadId'] as int : null,  // Se permite null
    fechaCreacion: json['FechaCreacionActividad'] != null ? formatDate(json['FechaCreacionActividad']) : null,  // Puede ser null
    fechaLimite: formatDate(json['FechaLimite'] ?? ''),  // Asegurarse de que fechaLimite nunca sea null
    materiaId: json['MateriaId'] as int? ?? 0,  // Asignar valor predeterminado si es null
    puntaje: json['Puntaje'] != null ? json['Puntaje'] as int : null,  // Se permite null
  );
  }
}
