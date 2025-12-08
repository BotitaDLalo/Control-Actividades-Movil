import 'package:aprende_mas/config/utils/packages.dart';
// auth provider removed from this widget to keep AppBarHome generic
import 'header_background.dart';

class AppBarHome extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettings;
  final Widget? leading;
  final double titleFontSize;

  const AppBarHome({
    super.key,
    required this.title,
    this.showSettings = true,
    this.leading,
    this.titleFontSize = 27,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // no read de auth aquí para evitar mostrar datos en pantallas públicas

    // altura deseada para el encabezado grande
    const double headerHeight = 150;

    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: headerHeight,
      flexibleSpace: const HeaderBackground(
        colorUno: Color.fromARGB(255, 8, 110, 154),
        colorDos: Color.fromARGB(255, 29, 183, 247),
      ),
      leading: leading,
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
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        ),
      ),
      actions: showSettings
          ? [
              Padding(
                padding: const EdgeInsets.only(top: 32, right: 12),
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: Container(
                    width: 50,
                    height: 50,
                    // Estilo del icono de configuración
                    child: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 30,
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(152);
}
