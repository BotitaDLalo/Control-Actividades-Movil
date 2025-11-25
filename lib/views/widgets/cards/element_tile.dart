import 'package:aprende_mas/config/utils/packages.dart';

class ElementTile extends ConsumerWidget {
  // final Notice notification;
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData? trailingIcon;
  final String? trailingString;
  final Color iconColor;
  final Color? trailingColor;
  final double iconSize;
  final GestureTapCallback? onTapFunction;
  final VoidCallback? trailingVoidCallback;
  final Widget? trailingWidget;

  const ElementTile({
    super.key,
    required this.icon,
    required this.iconColor,
    this.trailingColor,
    this.trailingString,
    required this.iconSize,
    required this.title,
    required this.subtitle,
    this.onTapFunction,
    this.trailingVoidCallback,
    this.trailingWidget,
    this.trailingIcon,
  });

  @override
// En el archivo de tu widget ElementTile

Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco
            borderRadius: BorderRadius.circular(10), // Bordes redondeados
            // Solo un borde sutil, sin sombra
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: ListTile(
            
            // --- Trailing (Ícono de tres puntos) ---
            trailing: trailingWidget ?? (
                trailingIcon != null
                    ? IconButton(
                        onPressed: trailingVoidCallback,
                        icon: Icon(
                          trailingIcon,
                          color: trailingColor,
                          size: 25,
                        ))
                    : Text(
                        trailingString ?? "",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )
            ),
            
            // --- Leading (Ícono de la actividad) ---
            leading: CircleAvatar(
              backgroundColor: Colors.transparent, 
              radius: 22,
              child: Icon(icon, color: Colors.black, size: iconSize),
            ),
            
            // --- Title (Título de la actividad) ---
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700, // Ajustado a W700 para que se vea más audaz
                color: Colors.black, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // --- Subtitle (Fecha/Descripción) ---
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  overflow: TextOverflow.ellipsis),
            ),
            onTap: onTapFunction),
      ),
    );
}
}