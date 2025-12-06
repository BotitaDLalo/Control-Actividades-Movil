import 'package:flutter/material.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final Widget? icon;
  final String? label;
  final String? hint;
  final String? errorMessage;
  final Function(dynamic)? onChanged;
  final FormFieldValidator? validator;
  final bool capitalizeFirstLetter;
  final double? customHeight;

  const CustomDropdown({
    super.key,
    this.icon,
    this.label,
    this.hint,
    this.errorMessage,
    this.onChanged,
    this.validator,
    this.capitalizeFirstLetter = false,
    this.customHeight,
    required this.items,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return DropdownButtonFormField(
      validator: validator,
      style: TextStyle(
        fontSize: context.fontSize(20), // Tamaño base 20, escalado responsive
        color: Colors.black,
      ),
      items: items.map((user) {
        return DropdownMenuItem<String>(
          value: user,
          child: Text(
            user,
            style: TextStyle(fontSize: context.fontSize(20)), // Tamaño base 20, escalado responsive
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: icon,
        floatingLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(18)), // Tamaño base 18, escalado responsive
        // No forzar bordes: respetar el InputDecorationTheme global
        isDense: true,
        label: label != null ? Text(label!) : null,
        hintText: hint,
        errorText: errorMessage,
        focusColor: colors.primaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.width(0.02), // 2% del ancho
          vertical: customHeight ?? context.height(0.02), // 2% de la altura por defecto
        ),
      ),
    );
  }
}
