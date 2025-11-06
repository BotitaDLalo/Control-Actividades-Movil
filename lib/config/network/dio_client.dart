import 'package:aprende_mas/config/environment/environment.dart';
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  //baseUrl: Environment.apiUrl,
  baseUrl: Environment.apiUrl.replaceFirst('http://', 'https://'),
  connectTimeout: const Duration(seconds: 30),
))..interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    print('Requesting: ${options.method} ${options.path}');
    return handler.next(options);
  },
  onResponse: (response, handler) {
    print('Response from: ${response.requestOptions.path}');
    return handler.next(response);
  },
  onError: (DioException e, handler) {
    print('DioException on path: ${e.requestOptions.path}');
    return handler.next(e);
  },
));
