import 'package:flutter/material.dart';

class HeaderBackground extends StatelessWidget {
  final Color colorUno;
  final Color colorDos;

  const HeaderBackground({
    super.key,
    required this.colorUno,
    required this.colorDos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorUno,
              colorDos,
            ]),
      ),
    );
  }
}
