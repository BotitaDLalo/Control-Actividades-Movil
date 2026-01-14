import 'package:flutter/material.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class CustomRoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? borderRadius;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomRoundedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFF00569E), // azul consistente con otros botones
    this.textColor = Colors.white,
    this.borderRadius,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Valores responsive por defecto
    final defaultBorderRadius = borderRadius ?? context.radius(0.05); // 5% del ancho
    final defaultHeight = height ?? context.height(0.06); // 6% de la altura
    final defaultPadding = padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8); // Padding fijo para consistencia

    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, defaultHeight)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
        padding: WidgetStatePropertyAll(defaultPadding),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16, // Tamaño fijo 16 para consistencia
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
