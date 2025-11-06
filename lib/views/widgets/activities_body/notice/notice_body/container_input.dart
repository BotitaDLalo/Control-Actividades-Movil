import 'package:aprende_mas/views/widgets/activities_body/notice/notice_body/input_notice_comment.dart';
import 'package:flutter/material.dart';

class ContainerInput extends StatelessWidget {
  const ContainerInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          const Icon(Icons.person, size: 30,),
          const SizedBox(width: 10,),
          InputNoticeComment(onPressed: () {})
        ],
      ),
    );
  }
}