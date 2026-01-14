import 'package:flutter/material.dart';

class ButtonLogin extends StatelessWidget {
  final String? text;
  final Color? textColor;
  final ButtonStyle? buttonStyle;
  final VoidCallback? onPressed;
  const ButtonLogin(
      {super.key, this.text, this.textColor, this.buttonStyle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0FA4E0),
      foregroundColor: Colors.white,
      elevation: 6,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    );

    return ElevatedButton(
        style: buttonStyle ?? defaultStyle,
        onPressed: onPressed,
        child: Text(
          text ?? "",
          style: TextStyle(color: textColor ?? Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ));
  }
}
