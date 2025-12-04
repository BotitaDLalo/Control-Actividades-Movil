import 'package:flutter/material.dart';

class CustomContainerStyle extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final Widget child;
  final Color? borderColor;

  const CustomContainerStyle({
    super.key, 
    required this.height, 
    required this.width, 
    required this.color, 
    required this.child, 
    this.borderColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0), // Sin bordes redondeados para cubrir todo
        border: Border.all(color: const Color.fromARGB(27, 0, 0, 0))
      ),
      child: child,
    );
  }
}