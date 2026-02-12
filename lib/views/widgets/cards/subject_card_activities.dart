import 'package:aprende_mas/models/models.dart';
import 'package:flutter/material.dart';

class CustomActivitiesContainer extends StatelessWidget {
  final Activity? actividades;
  
  const CustomActivitiesContainer({
    super.key, 
    required this.actividades,
  });

  String dateFormat(String date) {
    return date.substring(0, 10);
  }

  Widget _buildEstatus() {
    final actividad = actividades;
    if (actividad == null) return const SizedBox.shrink();

    final estatus = actividad.estatus ?? 'Pendiente';

    Color statusColor;
    String statusText;

    switch (estatus.toLowerCase()) {
      case 'entregado':
        statusColor = Colors.green;
        statusText = 'Entregado';
        break;
      case 'retrasado':
        statusColor = Colors.red;
        statusText = 'Retrasado';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${actividades?.nombreActividad.trim() ?? ""}\n',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextSpan(
                        text: "Asignada: ${dateFormat(actividades?.fechaCreacion.toString().trim() ?? "")}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              _buildEstatus(),
            ],
          ),
        ],
      ),
    );
  }
}
