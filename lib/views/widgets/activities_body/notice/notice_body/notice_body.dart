import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_body.dart';
import 'notice_description.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart'; // Asegúrate de tener NoticeModel aquí

class NoticeBody extends StatelessWidget {
  final bool optionsIsVisible;
  final NoticeModel notice;

  const NoticeBody({
    super.key,
    required this.optionsIsVisible,
    required this.notice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade300, 
        width: 1.0                              
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataBody(
            notice: notice,
            optionsIsVisible: optionsIsVisible,
          ),
          const SizedBox(height: 8),
          NoticeDescription(
            title: notice.title,
            content: notice.description,
            startDate: notice.startDate,
            endDate: notice.endDate,
            links: notice.links,
          ),
        ],
      ),
    );
  }
}