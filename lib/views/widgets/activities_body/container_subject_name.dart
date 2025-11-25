import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'custom_container_style.dart';

class ContainerNameGroupSubjects extends StatelessWidget {
  final String name;
  final String? accessCode;
  final Color color;
  const ContainerNameGroupSubjects(
      {super.key, required this.name, this.accessCode, required this.color});

  @override
  Widget build(BuildContext context) {
    // Color color(String colorCode) {
    //   if (colorCode == "") {
    //     return AppTheme.cardHeader;
    //   } else {
    //     return AppTheme.stringToColor(colorCode);
    //   }
    // }

    return CustomContainerStyle(
      height: 220,
      width: double.infinity,
      color: color,
      child: Stack(
        children: [
          // Flecha de regresar dentro del container
          Positioned(
            top: 36,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              tooltip: 'Regresar',
            ),
          ),
          // Iconos arriba derecha
          Positioned(
            top: 36,
            right: 24,
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Icon(Icons.notifications, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: color, size: 28),
                ),
              ],
            ),
          ),
          // Título y código abajo izquierda (siempre visible y alternativo si no hay código)
          Positioned(
            left: 24,
            right: 100,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Código de clase: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        (accessCode != null && accessCode!.isNotEmpty)
                          ? accessCode!
                          : 'Sin código',
                        style: TextStyle(
                          color: (accessCode != null && accessCode!.isNotEmpty)
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botón de ajustes circular abajo derecha
          Positioned(
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.settings, color: color, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
