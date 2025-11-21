import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final Icon? icon;
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
      style: const TextStyle(fontSize: 20, color: Colors.black),
      items: items.map((user) {
        return DropdownMenuItem<String>(
          value: user,
          child: Text(
            user,
            style: const TextStyle(fontSize: 20),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: icon,
        floatingLabelStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        // No forzar bordes: respetar el InputDecorationTheme global
        isDense: true,
        label: label != null ? Text(label!) : null,
        hintText: hint,
        errorText: errorMessage,
        focusColor: colors.primaryColor,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 8, vertical: customHeight ?? 15),
      ),
    );
  }
}
