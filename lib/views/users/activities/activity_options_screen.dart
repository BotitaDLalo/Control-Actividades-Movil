import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/widgets/buttons/floating_action_button_custom.dart';
import 'activity_list.dart';
import '../../teacher/activities/options/create_activies/button_create_general.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/models.dart';

class ActivityOptionScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectName;
  final bool buttonCreateIsVisible;
  final ButtonCreateGeneral? buttonCreateGeneral;
 
  const ActivityOptionScreen(
      {super.key,
      this.buttonCreateGeneral,
      required this.buttonCreateIsVisible,
      required this.subjectId,
      required this.subjectName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityOptionState();
}

class _ActivityOptionState extends ConsumerState<ActivityOptionScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void buttonModal() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.create),
                  title: const Text("Actividad"),
                  onTap: () {
                    final data = Subject(
                        materiaId: widget.subjectId,
                        nombreMateria: widget.subjectName);

                    context.push('/create-activities', extra: data);
                    context.pop();
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.assignment),
                //   title: const Text("Examen"),
                //   onTap: () {
                //     // Navigator.pop(context);
                //     // Agregar lógica para crear Examen
                //     context.go('/create-activity');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.attach_file),
                //   title: const Text("Archivo"),
                //   onTap: () {
                //     Navigator.pop(context);
                //     // Agregar lógica para subir Archivo
                //   },
                // ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: widget.buttonCreateIsVisible
          ? FloatingActionButtonCustom(
              voidCallback: () {
                buttonModal();
              },
              icon: Icons.add)
          : const SizedBox(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ButtonCreateGeneral(
            //     subjectId: widget.subjectId, subjectName: widget.subjectName),
            const SizedBox(height: 10),
            Expanded(
              child: ActivityList(
                subjectId: widget.subjectId,
                emptyBuilder: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 180,
                          child: SvgPicture.asset(
                            'assets/icons/add_activity.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Aquí podrás crear actividades,\nproyectos o evaluaciones para tus estudiantes',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
