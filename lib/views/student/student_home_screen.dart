import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/student/student.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:flutter/material.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'package:aprende_mas/views/widgets/snackbars/no_internet_snackbar.dart';


class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  static List<BottomNavigationBarItem> lsBarItems =
      CatalogButtonNavigationBarItems.lsBarItems;

  List<WidgetOptions> lsWidgetsOptions = [
    WidgetOptions(
      title: 'Agenda',
        bottomNavigationBarItem: lsBarItems[0],
        widget: const AgendaStudentScreen()),
    WidgetOptions(
      title: 'Grupos y Materias',
        bottomNavigationBarItem: lsBarItems[1],
        widget: const GroupsSubjectsStudentScreen()),
    WidgetOptions(
      title: 'Notificaciones',
        bottomNavigationBarItem: lsBarItems[2],
        widget: const NotificationsStudentScreen())
  ];

  @override
  Widget build(BuildContext context) {
    return HomeScreen(lsWidgetsOptions: lsWidgetsOptions);
  }
}
