import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DataBody extends ConsumerWidget {
  final bool optionsIsVisible;
  final NoticeModel notice; // ⬅️ Ahora recibe el modelo completo

  const DataBody({
    Key? key,
    required this.optionsIsVisible,
    required this.notice, // ⬅️ Cambiado a NoticeModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotices = ref.read(noticesFormProvider.notifier);
    
    // Extracción de datos del modelo para uso local
    final String teacherName = notice.teacherFullName ?? "Docente";
    final int noticeId = notice.noticeId ?? 0;
    final String createdDate = notice.createdDate.toString();


    // ---------------------------------------------------------
    // LÓGICA DE FORMATO DE FECHA (OPTIMIZADA)
    // ---------------------------------------------------------
    final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    // Usar locale 'es' para que se muestre correctamente "de MMMM"
    final outputFormatter = DateFormat('dd \'de\' MMMM \'a las\' hh:mm a', 'es'); 
    
    String formattedDate = createdDate;

    try {
      // 1. Intentar con el formato 'dd-MM-yyyy HH:mm:ss'
      final DateTime dateToFormat = inputFormatter.parse(createdDate);
      formattedDate = outputFormatter.format(dateToFormat);
    } catch (e) {
      try {
        // 2. Si falla, intentar parsear directamente como ISO 8601 (DateTime.parse)
        final DateTime dateToFormat = DateTime.parse(createdDate);
        formattedDate = outputFormatter.format(dateToFormat);
      } catch (e2) {
        // En caso de error total, se queda con la fecha original (createdDate)
        // Opcional: mostrar un valor por defecto o loggear el error
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
                formattedDate,
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
                  // NAVEGACIÓN CORREGIDA: Se pasa el modelo 'notice' completo
                  context.push('/teacher-create-notice', extra: notice);
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
                                // Usamos el ID del modelo
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