import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:flutter/material.dart';
import 'package:aprende_mas/views/teacher/notices/teacher_create_notice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';

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
                  // Mostrar diálogo de confirmación antes de eliminar
                  WarningConfirmationDialog.show(
                    context,
                    message: '¿Está seguro de que desea eliminar este aviso?',
                    onConfirmPressed: () async {
                      try {
                        // Usamos el ID del modelo
                        final success = await formNotices.onDeleteSubmit(noticeId);
                        if (success) {
                          // Mostrar mensaje de éxito
                          SuccessDialog.show(
                            context,
                            message: 'Aviso eliminado exitosamente',
                            onOkPressed: () {
                              // No es necesario hacer nada, el diálogo se cierra automáticamente
                            },
                          );
                        } else {
                          // Mostrar mensaje de error
                          ErrorDialog.show(
                            context,
                            message: 'No se pudo eliminar el aviso. Por favor, intente de nuevo.',
                          );
                        }
                      } catch (e) {
                        // Captura cualquier error en la eliminación del aviso
                        print("Error al eliminar el aviso: $e");
                        // Mostrar mensaje de error
                        ErrorDialog.show(
                          context,
                          message: 'Error al eliminar el aviso: $e',
                        );
                      }
                    },
                    onCancelPressed: () {
                      // No hacer nada, solo cerrar el diálogo
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