import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final Dio dio;
  String? _authToken;

  ApiService({String? baseUrl}) {
    final apiUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';
  //dio = Dio(BaseOptions(baseUrl: apiUrl, connectTimeout: const Duration(seconds: 15)));
  dio = Dio(BaseOptions(baseUrl: apiUrl.replaceFirst('http://', 'https://'), connectTimeout: const Duration(seconds: 15)));

    // Interceptor para logging y manejo de errores básico
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        
        // Añadir Authorization si existe token
        if (_authToken != null && !options.extra.containsKey('skipAuth')) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        
        // Intentar refresh en 401 si no se indicó skipRefresh
        final requestOptions = e.requestOptions;
        if (e.response?.statusCode == 401 && !(requestOptions.extra['retry'] == true)) {
          // Marcar para que no haga retry infinito
          requestOptions.extra['retry'] = true;
          try {
            // Aquí se espera que exista un manejador externo para refresh que llame a setAuthToken
            // Lanzamos un evento simple: si en el entorno global ya se actualizó token, reintentar
            // El proyecto debe implementar la lógica de refresh en AuthService y llamar api.setAuthToken
            // Esperamos brevemente para que el token sea actualizado si corresponde
            await Future.delayed(const Duration(milliseconds: 300));
            final newToken = _authToken; // después del refresh, setAuthToken debe haber actualizado esto
            if (newToken != null) {
              final opts = Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
                extra: requestOptions.extra,
              );
              final cloneReq = await dio.request(requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: opts);
              return handler.resolve(cloneReq);
            }
          } catch (_) {
            // ignore
          }
        }
        return handler.next(e);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {data, Options? options}) async {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {data, Options? options}) async {
    return dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {data, Options? options}) async {
    return dio.delete(path, data: data, options: options);
  }
}
