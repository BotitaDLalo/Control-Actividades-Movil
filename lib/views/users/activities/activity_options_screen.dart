import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/views/widgets/buttons/floating_action_button_custom.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
import 'package:aprende_mas/providers/activity/activity_provider.dart';
import 'activity_list.dart';
import '../../teacher/activities/options/create_activies/button_create_general.dart';
//import 'package:aprende_mas/config/utils/utils.dart';
//import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/models/models.dart';

class ActivityOptionScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectName;
  final bool buttonCreateIsVisible;
  final ButtonCreateGeneral? buttonCreateGeneral;

  const ActivityOptionScreen({
    super.key,
    this.buttonCreateGeneral,
    required this.buttonCreateIsVisible,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActivityOptionState();
}

class _ActivityOptionState extends ConsumerState<ActivityOptionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = getSubjectColor(widget.subjectId);
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
                  leading: SvgPicture.asset('assets/icons/agregarActividad.svg', width: 24, height: 24),
                  title: const Text("Nueva actividad"),
                  onTap: () {
                    final data = Subject(
                      materiaId: widget.subjectId,
                      nombreMateria: widget.subjectName,
                    );

                    context.push('/create-activities', extra: data);
                    context.pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final activitiesAsync = ref.watch(activitiesBySubjectProvider(widget.subjectId));

        return activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Center(child: Text('Error al cargar actividades.')),
          data: (lsActivities) {
            final floatingButton =
                (widget.buttonCreateIsVisible && lsActivities.isNotEmpty)
                    ? FloatingActionButtonCustom(
                        voidCallback: () {
                          buttonModal();
                        },
                        icon: Icons.add,
                        backgroundColor: subjectColor,
                      )
                    : null;

            return Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: lsActivities.isEmpty
                    ? widget.buttonCreateIsVisible
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: SvgPicture.asset(
                                      'assets/icons/agregarActividad.svg',
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.contain,
                                      colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Aquí podrás crear actividades,\nproyectos o evaluaciones para tus estudiantes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: 300,
                                    child: CustomRoundedButton(
                                      text: 'Crear primera actividad',
                                      onPressed: () {
                                        buttonModal();
                                      },
                                      backgroundColor: subjectColor,
                                      textColor: Colors.white,
                                      borderRadius: 24,
                                      height: 56,
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/sleep1.svg',
                                    height: 170,
                                    width: 170,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Excelente, no tienes actividades pendientes para esta materia',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : ActivityList(
                        subjectId: widget.subjectId,
                        nombreMateria: widget.subjectName,
                      ),
              ),
            ),

            if (floatingButton != null)
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: floatingButton,
              ),
          ],
        );
          },
        );
      },
    );
  }
}