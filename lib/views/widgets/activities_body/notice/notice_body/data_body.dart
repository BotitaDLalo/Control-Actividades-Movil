import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DataBody extends ConsumerWidget {
  final bool optionsIsVisible;
  final NoticeModel notice;

  const DataBody({
    Key? key,
    required this.optionsIsVisible,
    required this.notice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotices = ref.read(noticesFormProvider.notifier);

    final String teacherName = notice.teacherFullName ?? "Docente";
    final int noticeId = notice.noticeId ?? 0;
    final String createdDate = notice.createdDate.toString();

    // ---------------------------------------------------------
    // FORMATO DE FECHA
    // ---------------------------------------------------------
    final inputFormatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    final outputFormatter =
        DateFormat('dd \'de\' MMMM \'a las\' hh:mm a', 'es');

    String formattedDate = createdDate;

    try {
      final DateTime dateToFormat = inputFormatter.parse(createdDate);
      formattedDate = outputFormatter.format(dateToFormat);
    } catch (e) {
      try {
        final DateTime dateToFormat = DateTime.parse(createdDate);
        formattedDate = outputFormatter.format(dateToFormat);
      } catch (e2) {
        // Si falla, se deja la fecha original
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

        // ----------------------------------------------------------------
        // OPCIONES (EDITAR / ELIMINAR)
        // ----------------------------------------------------------------
        if (optionsIsVisible)
          PopupMenuButton(
            color: Colors.white,
            elevation: 10.0,
            iconSize: 30,
            popUpAnimationStyle: AnimationStyle(curve: Curves.slowMiddle),

            // Manejo correcto del tap del menú
            onSelected: (value) {
              if (value == 'edit') {
                Future.microtask(() {
                  context.push(
                    '/teacher-create-notice',
                    extra: {
                      'notice': notice,
                      'subjectName': notice.subjectName, // ← SIEMPRE enviado
                    },
                  );
                });
              }

              if (value == 'delete') {
                Future.microtask(() {
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
                            onPressed: () => context.pop(),
                            style: AppTheme.buttonPrimary,
                            child: const Text(
                              'Cancelar',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: SizedBox(
                  width: 90,
                  child: Text('Editar', style: TextStyle(fontSize: 20)),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: SizedBox(
                  width: 90,
                  child: Text('Eliminar', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
