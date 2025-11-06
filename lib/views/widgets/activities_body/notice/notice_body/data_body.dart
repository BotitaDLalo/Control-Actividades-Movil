import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';

class DataBody extends ConsumerWidget {
  final int noticeId;
  final String teacherName;
  final String createdDate;
  final bool optionsIsVisible;
  const DataBody(
      {super.key,
      required this.optionsIsVisible,
      required this.noticeId,
      required this.teacherName,
      required this.createdDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formNotices = ref.read(noticesFormProvider.notifier);

    ref.listen(
      noticesFormProvider,
      (previous, next) {
        // if (next.isDeleted && !next.isPosting) {
        //   successMessage(context, 'Se elimino el aviso.');
        // }else if(!next.isDeleted && !next.isPosting){
        //   errorMessage(context, 'Hubo un error');
        // }
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.black,
              radius: 22,
              child: Icon(Icons.person, color: Colors.white, size: 33)),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacherName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text(
                  createdDate,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),

          if(optionsIsVisible)
          PopupMenuButton(
            color: Colors.white,
            elevation: 10.0,
            iconSize: 30,
            popUpAnimationStyle: AnimationStyle(curve: Curves.slowMiddle),
            itemBuilder: (context) => [
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
              // const PopupMenuItem(
              //     child: Text(
              //   'Eliminar',
              //   style: TextStyle(fontSize: 18),
              // )),
            ],
          )
        ],
      ),
    );
  }
}

// ElementTile(icon: Icons.person, iconColor: Colors.white, iconSize: 33, title: teacherName, subtitle: createdDate)
