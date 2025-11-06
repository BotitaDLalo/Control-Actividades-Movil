import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/message/message.dart';

final chatProvider = ChangeNotifierProvider((ref) => ChatProvider());

class ChatProvider extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController(); 
  final TextEditingController controller = TextEditingController();
  final List<Message> _messages = [];
  final List<DateTime> requestTimestamps = [];

  List<Message> get messages => _messages;

    Future<void> callGeminiModel(String prompt) async {
    final now = DateTime.now();

    // Filtrar las solicitudes de los últimos 60 segundos
    requestTimestamps.removeWhere((timestamp) => now.difference(timestamp).inSeconds > 60);

    // Si se hicieron más de 5 peticiones en el último minuto, bloquear
    if (requestTimestamps.length >= 3) {
      debugPrint('Límite de peticiones alcanzado. Espera un momento.');
      return;
    }

    requestTimestamps.add(now); // Registrar la nueva petición
    notifyListeners();

    try {
      _messages.add(Message(text: prompt, isUser: true));
      notifyListeners();

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: dotenv.env['GOOGLE_API_KEY']!);
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      String cleanAnswer = cleanText(response.text ?? "");

    _messages.add(Message(text: cleanAnswer, isUser: false));
      notifyListeners();
      moveScrollToBottom();
    } catch (e) {
      debugPrint('Error al llamar a Gemini: $e');
    }
  }

  String cleanText(String texto) {
  return texto.replaceAll(RegExp(r'[*#]+'), '').trim();
}


  void moveScrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    }
  });
}

}