import 'package:flutter/material.dart';

class NoticeDescription extends StatelessWidget {
  final String title; 
  final String content;

  const NoticeDescription({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          title, 
           style: const TextStyle(
            fontWeight: FontWeight.bold,
             fontSize: 15, 
             height: 1.4, 
             color: Colors.black87,
           ),
         ),


        Text(
          content, 
          style: const TextStyle(
            fontSize: 15, 
            height: 1.4, 
            color: Colors.black87,
          ),
        ),
        // No hay "Archivo adjunto" en la imagen que se pide reproducir
      ],
    );
  }
}
