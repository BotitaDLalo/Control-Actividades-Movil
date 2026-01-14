import 'package:aprende_mas/config/environment/environment.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/utils/packages.dart';

final aiActivityProvider = ChangeNotifierProvider((ref) => AIActivity());

class AIActivity extends ChangeNotifier {
  final List<DateTime> requestTimestamps = [];

  Future<String?> generateActivitySuggestion(String prompt) async {
    final now = DateTime.now();

    // Filtrar las solicitudes de los últimos 60 segundos
    requestTimestamps
        .removeWhere((timestamp) => now.difference(timestamp).inSeconds > 60);

    // Si se hicieron más de 3 peticiones en el último minuto, bloquear
    if (requestTimestamps.length >= 3) {
      debugPrint('Límite de peticiones alcanzado. Espera un momento.');
      return null;
    }

    requestTimestamps.add(now); // Registrar la nueva petición
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: Environment.apiGeminiModel,
        apiKey: Environment.apiKeyGoogle,
      );

final content = [
  Content.text(
    'A partir de la siguiente actividad: "$prompt", '
    'genera **tres versiones mejoradas de la descripción**, más claras, completas y bien estructuradas. '
    'Cada versión debe incluir detalles útiles sin cambiar el significado original. '
    'No incluyas introducciones ni explicaciones, solo proporciona las tres versiones numeradas (1, 2 y 3).'
  )
];



      final response = await model.generateContent(content);

      return cleanText(response.text ?? "");
    } catch (e) {
      debugPrint('Error al llamar a Gemini: $e');
      return null;
    }
  }

  String cleanText(String texto) {
    return texto.replaceAll(RegExp(r'[*#]+'), '').trim();
  }
}
