import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static late String apiUrl;

  static Future<void> initEnvironment() async {
    await dotenv.load(fileName: ".env");
    apiUrl = dotenv.env['API_URL'] ?? 'https://controlactividades20251017143449sx.azurewebsites.net';
  }
}