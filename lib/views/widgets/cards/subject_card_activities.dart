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
                        text: '${actividades?.nombreActividad?.trim() ?? "Sin nombre"}\n',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextSpan(
                        text: "Asignada: ${dateFormat(actividades?.fechaCreacion?.toString()?.trim() ?? "Sin fecha")}",
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
            ],
          ),
        ],
      ),
    );
  }
}
