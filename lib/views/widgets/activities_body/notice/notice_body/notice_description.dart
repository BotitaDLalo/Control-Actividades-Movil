import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDescription extends StatelessWidget {
  final String title; 
  final String content;
  final String? startDate;
  final String? endDate;
  final String? links;

  const NoticeDescription({
    Key? key,
    required this.title,
    required this.content,
    this.startDate,
    this.endDate,
    this.links,
  }) : super(key: key);

  // Helper para lanzar URL
  Future<void> _launchUrl(String urlString) async {
    // Agrega 'https://' si no está presente para asegurar que sea una URL válida
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Opcional: Mostrar un snackbar o loggear el error
      debugPrint('No se pudo abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> linkList = [];
    if (links != null && links!.isNotEmpty) {
      try {
        final decoded = jsonDecode(links!);
        if (decoded is List) {
          linkList = List<String>.from(decoded.map((e) => e.toString()));
        }
      } catch (e) {
        // Si no es un JSON válido, lo trata como un solo enlace (o enlaces separados por comas)
        linkList = links!.split(',').map((link) => link.trim()).where((link) => link.isNotEmpty).toList();
      }
    }

    // Helper para obtener solo la fecha de un string 'dd-MM-yyyy HH:mm:ss'
    String getDateOnly(String? dateTimeString) {
      return dateTimeString?.split(' ').first ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          title, 
           style: const TextStyle(
            fontWeight: FontWeight.bold,
             fontSize: 18, 
             height: 1.4, 
             color: Colors.black87,
           ),
         ),


        Text(
          content, 
          style: const TextStyle(
            fontSize: 16, 
            height: 1.4, 
            color: Colors.black87,
          ),
        ),

        // Widget para mostrar las fechas de vigencia
        if (startDate != null && startDate!.isNotEmpty && endDate != null && endDate!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                Icon(Icons.date_range_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Vigencia: ${getDateOnly(startDate)} - ${getDateOnly(endDate)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Widget para mostrar los enlaces
        if (linkList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linkList.length > 1 ? 'Enlaces:' : 'Enlace:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                ...linkList.map((link) {
                  return InkWell(
                    onTap: () => _launchUrl(link),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              link,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }
}
