import 'package:aprende_mas/config/environment/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final dio = Dio(BaseOptions(
  baseUrl: Environment.apiUrl,
  connectTimeout: const Duration(seconds: 30),
  validateStatus: (status) =>
      true,
))
  ..interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) {
      debugPrint(obj.toString());
    },
  ));
