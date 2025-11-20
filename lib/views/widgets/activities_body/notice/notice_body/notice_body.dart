import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_body.dart';
import 'notice_description.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class NoticeBody extends StatelessWidget {
  final bool optionsIsVisible;
  final int noticeId;
  final String teacherName;
  final String createdDate;
  final String title;
  final String content;

  const NoticeBody({
    super.key,
    required this.optionsIsVisible,
    required this.noticeId,
    required this.teacherName,
    required this.createdDate,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),   
        border: Border.all(
          color: const Color(0xFF999494),                     
          width: 1.3,                              
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataBody(
            teacherName: teacherName,
            createdDate: createdDate,
            noticeId: noticeId,
            optionsIsVisible: optionsIsVisible,
          ),
          const SizedBox(height: 8),
          NoticeDescription(
            title: title,
            content: content,
          ),
        ],
      ),
    );
  }
}

