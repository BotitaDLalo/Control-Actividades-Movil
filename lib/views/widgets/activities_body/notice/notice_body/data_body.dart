import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea la parte superior
      children: [
        // Eliminamos el CircleAvatar 
        // const CircleAvatar(
        //   radius: 20, // Ajusta el radio según sea necesario
        //   backgroundColor: Colors.grey, // Color de fondo si no hay imagen
        //   child: Icon(Icons.person, color: Colors.white), // Icono por defecto
        // ),
        // const SizedBox(width: 8), // Espacio entre el avatar y el texto

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
                createdDate, 
                style: const TextStyle(
                  fontSize: 12, 
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
                // ------------------------------------------
                // NUEVA OPCIÓN: EDITAR
                // ------------------------------------------
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
                
                // ------------------------------------------
                // OPCIÓN EXISTENTE: ELIMINAR
                // ------------------------------------------
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