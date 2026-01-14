import 'package:flutter/material.dart';

class ButtonActivityForm extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;

  const ButtonActivityForm(
      {super.key, required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0FA4E0),
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        onPressed: onPressed,
        child: Text(buttonName));
  }
}
