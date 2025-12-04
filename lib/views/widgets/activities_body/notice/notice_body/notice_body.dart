import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_body.dart';
import 'notice_description.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart'; // Asegúrate de tener NoticeModel aquí

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
    // 🚨 CREAMOS EL MODELO A PARTIR DE LOS PARÁMETROS:
    final NoticeModel noticeData = NoticeModel(
      noticeId: noticeId,
      teacherFullName: teacherName,
      createdDate: createdDate,
      title: title,
      description: content,
      // Los campos groupId y subjectId se dejan por defecto o se pasan si son necesarios
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // 🚨 CAMBIO AQUÍ: PASAMOS EL MODELO COMPLETO
            notice: noticeData, 
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