import 'package:flutter/material.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class CustomTextFormField extends StatelessWidget {
  final Widget? icon;
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
  final String? initialValue;

  const CustomTextFormField({
    super.key,
    this.icon,
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
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return TextFormField(
      cursorColor: Colors.black,
      controller: textEditingController,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: isNumericKeyboard ? TextInputType.number : keyboardType,
      maxLines: enableLineBreak ? null : 1,
      textCapitalization: capitalizeFirstLetter
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      style: TextStyle(
        fontSize: context.fontSize(20), // Tamaño base 20, escalado responsive
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: icon,
        floatingLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(18)), // Tamaño base 18, escalado responsive
        // No definir bordes explícitos aquí para respetar el InputDecorationTheme global
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

