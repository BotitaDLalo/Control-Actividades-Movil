import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomInputMessage extends StatelessWidget {
  final TextEditingController controller;
  final void Function() onPressed;

  const CustomInputMessage(
      {super.key, required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 32.0, top: 16.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          // TextField en recuadro redondeado (pastilla)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 191, 230, 255), //Color de la forma pastilla
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 1,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Envia una pregunta',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(0, 207, 49, 49), // Linea del textfield
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(color: const Color.fromARGB(255, 123, 142, 149)), // Color texto etiqueta
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón de envío en círculo azul
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 121, 216),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/send1.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
