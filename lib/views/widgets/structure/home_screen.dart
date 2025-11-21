import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/config/utils/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<WidgetOptions> lsWidgetsOptions;
  const HomeScreen({super.key, required this.lsWidgetsOptions});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // int selectedIndex = 0;
  final itemTappedProvider = StateProvider<int>((ref) => 0);

  void onItemTapped(int index) {
    ref.read(itemTappedProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final element =
        widget.lsWidgetsOptions.elementAt(ref.watch(itemTappedProvider));

    final auth = ref.read(authProvider);

    void logoutClearStates() {
      if (auth.authGoogleStatus == AuthGoogleStatus.authenticated) {
        ref.read(authProvider.notifier).logoutGoogle();
      } else if (auth.authStatus == AuthStatus.authenticated) {
        ref.read(authProvider.notifier).logout();
      }
      ref.read(notificationsProvider.notifier).clearNotifications();
      ref.read(activityProvider.notifier).clearActivityState();
      ref.read(groupsProvider.notifier).clearGroupsState();
      ref.read(subjectsProvider.notifier).clearSubjectsState();
    }

    return Scaffold(
      endDrawer: SizedBox(
        width: 280,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Header con gradiente, avatar y datos del usuario
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 3, 95, 153),
                      Color.fromARGB(255, 29, 183, 247),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color.fromARGB(255, 5, 164, 204),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      auth.authUser?.userName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.authUser?.role ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Opciones del drawer
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                  size: 30,
                ),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  logoutClearStates();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBarHome(
        title: element.title,
      ),
      // Espacio superior entre el AppBar y el contenido
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Center(
          child: element.widget,
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: ref.watch(itemTappedProvider),
        onItemSelected: onItemTapped,
        widgetsOptionsItems: widget.lsWidgetsOptions
            .map((e) => e.bottomNavigationBarItem)
            .toList(),
      ),
    );
  }
}
