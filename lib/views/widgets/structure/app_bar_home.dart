import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'header_background.dart';

class AppBarHome extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  const AppBarHome({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    String displayEmail() {
      try {
        final email = auth.authUser?.email ?? '';
        return email.isNotEmpty ? email : (auth.authUser?.userName ?? '');
      } catch (_) {
        return '';
      }
    }

    // altura deseada para el encabezado grande
    const double headerHeight = 150;

    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: headerHeight,
      flexibleSpace: const HeaderBackground(
        colorUno: Color.fromARGB(255, 53, 167, 239),
        colorDos: Color.fromARGB(255, 53, 217, 239),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /*
            // Estilo de texto para el correo electrónico
            Text(
              displayEmail(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            */
            const SizedBox(height: 6),
            // Estilo de texto para el título principal
            Text(
              title,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 32, right: 12),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: Container(
              width: 50,
              height: 50,
              /*
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 8, 70, 125),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              */
              // Estilo del icono de configuración
              child: const Icon(
                Icons.settings,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(152);
}
