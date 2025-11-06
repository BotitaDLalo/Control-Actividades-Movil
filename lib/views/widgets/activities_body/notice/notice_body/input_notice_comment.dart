import 'package:flutter/material.dart';

class InputNoticeComment extends StatelessWidget {
  final void Function() onPressed;

  const InputNoticeComment({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, right: 8.0),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Añadir comentario',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.send,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
