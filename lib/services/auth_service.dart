
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api;
  final FlutterSecureStorage storage;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  AuthService({ApiService? apiService, FlutterSecureStorage? storage})
      : api = apiService ?? ApiService(),
        storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens(String token, {String? refreshToken}) async {
    await storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) await storage.write(key: _refreshTokenKey, value: refreshToken);
    api.setAuthToken(token);
  }

  Future<String?> get token async => await storage.read(key: _tokenKey);
  Future<String?> get refreshToken async => await storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  Future<Response> login(String email, String password) async {
    final resp = await api.post('/api/Login/InicioSesionUsuario', data: {'Correo': email, 'Clave': password});
    // Ajusta según la respuesta real del backend
    if (resp.statusCode == 200) {
      final data = resp.data;
      final token = data['accessToken'] ?? data['token'] ?? data['access_token'];
      final refresh = data['refreshToken'] ?? data['refresh_token'];
      if (token != null) await saveTokens(token, refreshToken: refresh);
    }
    return resp;
  }

  /// Llama al endpoint de refresh del backend. Ajusta la ruta y el payload según tu API.
  Future<bool> tryRefreshToken() async {
    final r = await refreshToken;
    if (r == null) return false;
    try {
      final resp = await api.post('/auth/refresh', data: {'refreshToken': r},
          // evitamos interceptor de retry en este request
          );
      if (resp.statusCode == 200) {
        final data = resp.data;
        final newToken = data['accessToken'] ?? data['token'] ?? data['access_token'];
        final newRefresh = data['refreshToken'] ?? data['refresh_token'];
        if (newToken != null) {
          await saveTokens(newToken, refreshToken: newRefresh);
          return true;
        }
      }
    } catch (e) {
      // refresh falló
    }
    await clear();
    return false;
  }

  Future<Response> register(Map<String, dynamic> payload) async {
    return api.post('/api/Login/RegistroUsuario', data: payload);
  }

  /// Ejemplo de llamada autenticada
  Future<Response> getProfile() async {
    final t = await token;
    final options = Options(headers: {'Authorization': 'Bearer $t'});
    return api.get('/user/profile', options: options);
  }
}
