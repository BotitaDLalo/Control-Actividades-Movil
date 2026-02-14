import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ElementTile extends ConsumerWidget {
  // final Notice notification;
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final IconData? trailingIcon;
  final String? trailingString;
  final Color iconColor;
  final Color? trailingColor;
  final double iconSize;
  final GestureTapCallback? onTapFunction;
  final VoidCallback? trailingVoidCallback;
  final Widget? trailingWidget;
  final String? bottomText; // Nuevo: texto en la parte inferior
  final Color? bottomTextColor; // Nuevo: color del texto inferior
  final Widget? footerWidget; // Widget para el footer (estatus)

  const ElementTile({
    super.key,
    this.icon,
    this.iconWidget,
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
    this.bottomText,
    this.bottomTextColor,
    this.footerWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 15.0, left: 8.0, right: 8.0),
      child: Container(
        height: 155, // Altura fija para la card
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: ListTile(
          // --- Trailing (Ícono de eliminar) ---
          trailing: trailingWidget ?? (
              trailingIcon != null
                  ? IconButton(
                      onPressed: trailingVoidCallback,
                      icon: Icon(
                        trailingIcon,
                        color: trailingColor,
                        size: 40, // Mismo tamaño que el borrador
                      ))
                  : IconButton(
                      onPressed: trailingVoidCallback,
                      icon: SvgPicture.asset(
                        'assets/icons/eliminar4.svg',
                        width: 40, // Mismo tamaño que el borrador
                        height: 40,
                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      ),
                    )
          ),
          
          // --- Leading (Ícono de la actividad) ---
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 35, // Mismo radio que el borrador
            child: iconWidget ?? (icon != null ? Icon(icon, color: Colors.black, size: 50) : const SizedBox()),
          ),
          
          // --- Title (Título de la actividad) ---
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18, // Mismo tamaño que el borrador
              fontWeight: FontWeight.w700,
              color: Colors.black, 
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // --- Subtitle (Fecha/Descripción) ---
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subtitle,
                maxLines: 3,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis),
              ),
              if (footerWidget != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: footerWidget!,
                ),
              ] else if (bottomText != null) ...[
                const SizedBox(height: 4),
                Text(
                  bottomText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: bottomTextColor ?? Colors.green,
                  ),
                ),
              ],
            ],
          ),
          onTap: onTapFunction,
        ),
      ),
    );
  }
}
