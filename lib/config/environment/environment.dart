import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl =
      dotenv.env['API_URL'] ?? 'No esta configurado el API_URL';

  static String apiKeyGoogle = dotenv.env['GOOGLE_API_KEY'] ?? '';

  static String apiGeminiModel = dotenv.env['GEMINI_API_MODEL_VERSION'] ?? '';
}
