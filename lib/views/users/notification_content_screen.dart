import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationContentScreen extends StatelessWidget {
    IconData _getNotificationIcon(String title) {
      final lower = title.toLowerCase();
      if (lower.contains('aviso')) {
        return Icons.campaign; // Icono para avisos
      } else if (lower.contains('actividad')) {
        return Icons.assignment; // Icono para actividades
      }
      return Icons.notifications; // Icono por defecto
    }
  final String messageId;
  final String title;
  final String body;
  final String sentDate;

  const NotificationContentScreen(
      {super.key,
      required this.messageId,
      required this.title,
      required this.body,
      required this.sentDate});

String _formatDate(String rawDate) {
  try {
    final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final date = inputFormat.parse(rawDate).toLocal();

    final outputFormat = DateFormat(
      "d 'de' MMMM 'de' yyyy 'a las' h:mm a",
      'es_ES',
    );

    return outputFormat
        .format(date)
        .replaceAll('AM', 'a. m.')
        .replaceAll('PM', 'p. m.');
  } catch (e) {
    return rawDate;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNotificationIcon(title),
                  color: Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
              // ...existing code...
            const SizedBox(height: 8),
            Text(
              _formatDate(sentDate),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              body,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
