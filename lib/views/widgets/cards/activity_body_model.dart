import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityBodyModel extends StatelessWidget {
  final String nombreActividad;
  final DateTime fechaCreacion;
  final DateTime fechaLimite;
  final String descripcion;
  final int subjectId;

  const ActivityBodyModel({
    super.key, 
    required this.nombreActividad,
    required this.fechaCreacion, 
    required this.fechaLimite, 
    required this.descripcion, 
    required this.subjectId,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomContainerStyle(
        height: 250,
        width: double.infinity,
        color: Colors.white,
        borderColor: Colors.blue,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreActividad, // Nombre dinámico
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Publicado: ${_formatDate(fechaCreacion)} ${_formatTime(fechaCreacion)}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 40,
                ),
               Column(
        children: [
          const Text(
            'Fecha de entrega :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            '${_formatDate(fechaLimite)} ${_formatTime(fechaLimite)}',
            style: const TextStyle(fontSize: 8),
          )
        ],
      ) // Fecha límite
              ],
            ),
            const _CustomDivider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                descripcion, // Descripción dinámica
                style: const TextStyle(fontSize: 10),
              ),
            ), // Descripción dinámica
            const _CustomDivider(),
            const Text(
              'Ver Completo',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 10, left: 10),
      child: Divider(
        color: Colors.grey,
      ),
    );
  }
}