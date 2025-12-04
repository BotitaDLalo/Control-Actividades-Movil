import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:flutter/material.dart';

class CustomHeaderContainer extends StatelessWidget {
  final String nombreMateria;
  const CustomHeaderContainer({
    super.key,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(16),
      decoration:BoxDecoration(
          color: AppTheme.mainColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Text(
        nombreMateria,
          style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }
}