import 'package:flutter/material.dart';

class ButtonCreateActivitiesBetter extends StatelessWidget {
  final VoidCallback? onPressed;

  const ButtonCreateActivitiesBetter({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: SizedBox(
        width: double.infinity,
        height: 50, // altura fija para mantenerlo rectangular
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.grey),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // esquinas menos redondeadas
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          child: const Text(
            'Crear',
            style: TextStyle(
              color: Colors.black, // texto negro
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
