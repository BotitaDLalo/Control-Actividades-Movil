import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Icon? icon;
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
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return TextFormField(
      cursorColor: Colors.black,
      controller: textEditingController,
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
          prefixIcon: icon,
          floatingLabelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),

          // --- BORDES NORMAL Y FOCUSED REDONDEADOS ---
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(100, 0, 0, 0)),
            borderRadius: BorderRadius.circular(15),   // ← redondeado
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
            borderRadius: BorderRadius.circular(15),   // ← redondeado
          ),

          // --- BORDES EN ERROR ---
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade800),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade800),
            borderRadius: BorderRadius.circular(30),
          ),

          isDense: true,
          label: label != null ? Text(label!) : null,
          hintText: hint,
          errorText: errorMessage,
          focusColor: colors.primaryColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: customHeight ?? 15,
          ),
        )

    );
  }
}

