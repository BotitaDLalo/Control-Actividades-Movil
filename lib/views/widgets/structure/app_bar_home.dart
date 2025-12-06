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

    // altura deseada para el encabezado grande - responsive
    final headerHeight = context.height(0.2); // 20% del alto de pantalla

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
        padding: EdgeInsets.only(top: context.height(0.025)), // 2.5% del alto
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /*
            // Estilo de texto para el correo electrónico
            Text(
              displayEmail(),
              style: TextStyle(
                fontSize: context.fontSize(18), // Tamaño base 18, escalado responsive
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            */
            SizedBox(height: context.height(0.008)), // 0.8% del alto
            // Estilo de texto para el título principal
            Text(
              title,
              style: TextStyle(
                fontSize: context.fontSize(titleFontSize), // titleFontSize escalado responsive
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
                padding: EdgeInsets.only(
                  top: context.height(0.04), // 4% del alto
                  right: context.width(0.03), // 3% del ancho
                ),
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: Container(
                    width: context.width(0.125), // 12.5% del ancho
                    height: context.width(0.125), // 12.5% del ancho (mantiene proporción cuadrada)
                    // Estilo del icono de configuración
                    child: Icon(
                      Icons.settings,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: context.width(0.075), // 7.5% del ancho
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.height * 0.205); // 20.5% del alto + pequeño margen
}
