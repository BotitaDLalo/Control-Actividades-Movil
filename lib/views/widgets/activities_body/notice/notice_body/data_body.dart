import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import eliminado: 'package:app_teacher_notice/src/notices/application/forms/notices_form_provider.dart';

class DataBody extends ConsumerWidget {
  final bool optionsIsVisible;
  final int noticeId;
  final String teacherName;
  final String createdDate;

  const DataBody({
    Key? key,
    required this.optionsIsVisible,
    required this.noticeId,
    required this.teacherName,
    required this.createdDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotices = ref.read(noticesFormProvider.notifier);

    // ---------------------------------------------------------
    // 2. LÓGICA DE FORMATO DE FECHA
    // ---------------------------------------------------------
    // Definimos el formato de entrada (basado en tu error anterior: 24-11-2025 12:00:00)
    final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    
    // Definimos el formato de salida deseado en español
    final outputFormatter = DateFormat('dd \'de\' MMMM \'a las\' hh:mm a', 'es');
    
    String formattedDate = createdDate; // Valor por defecto por si falla

    try {
      // Intentamos parsear con el formato específico
      final DateTime dateToFormat = inputFormatter.parse(createdDate);
      formattedDate = outputFormatter.format(dateToFormat);
    } catch (e) {
      // Si falla (por ejemplo, si la fecha viene en otro formato ISO), intentamos el parseo genérico
      try {
        final DateTime dateToFormat = DateTime.parse(createdDate);
        formattedDate = outputFormatter.format(dateToFormat);
      } catch (e2) {
        // Si todo falla, se queda con el texto original 'createdDate'
        print('No se pudo formatear la fecha: $createdDate');
      }
    }
    // ---------------------------------------------------------

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacherName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate, // <--- 3. USAMOS LA FECHA FORMATEADA AQUÍ
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (optionsIsVisible)
          PopupMenuButton(
            color: Colors.white,
            elevation: 10.0,
            iconSize: 30,
            popUpAnimationStyle: AnimationStyle(curve: Curves.slowMiddle),
            itemBuilder: (context) => [
              // Opción Editar
              PopupMenuItem(
                  onTap: () {
                    // Funcionalidad pendiente
                  },
                  child: const SizedBox(
                      width: 90,
                      child: Text(
                        'Editar',
                        style: TextStyle(fontSize: 20),
                      ))),
              // Opción Eliminar
              PopupMenuItem(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            '¿Desea eliminar el aviso?',
                            style: TextStyle(fontSize: 22),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: AppTheme.buttonPrimary,
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                                style: AppTheme.buttonPrimary,
                                onPressed: () {
                                  formNotices.onDeleteSubmit(noticeId);
                                  context.pop();
                                },
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ))
                          ],
                        );
                      },
                    );
                  },
                  child: const SizedBox(
                      width: 90,
                      child: Text(
                        'Eliminar',
                        style: TextStyle(fontSize: 20),
                      ))),
            ],
          )
      ],
    );
  }
}