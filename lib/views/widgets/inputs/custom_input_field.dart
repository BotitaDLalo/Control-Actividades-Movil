import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? textEditingController;
  final bool enableLineBreak;
  final bool capitalizeFirstLetter;
  final double? customHeight;
  final bool isNumericKeyboard;
  final String initialValue; // Ahora es obligatorio

  const CustomInputField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textEditingController,
    this.enableLineBreak = false,
    this.capitalizeFirstLetter = false,
    this.customHeight,
    this.isNumericKeyboard = false,
    required this.initialValue, // Obligatorio
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return TextFormField(
      controller: textEditingController ?? TextEditingController(text: initialValue),
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: isNumericKeyboard ? TextInputType.number : keyboardType,
      maxLines: enableLineBreak ? null : 1,
      textCapitalization: capitalizeFirstLetter
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      style: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        // Dejar que el tema global maneje los bordes y colores
        isDense: true,
        label: label != null ? Text(label!) : null,
        hintText: hint,
        errorText: errorMessage,
        focusColor: colors.primaryColor,
        contentPadding: EdgeInsets.symmetric(
            horizontal: 8, vertical: customHeight ?? 15),
      ),
    );
  }
}
