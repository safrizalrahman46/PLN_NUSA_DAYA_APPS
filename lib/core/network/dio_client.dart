import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_config.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

/// Fungsi helper untuk membaca token dari secure storage
Future<String?> _readSecureToken() async {
  const storage = FlutterSecureStorage();
  return storage.read(key: 'auth_token');
}

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _readSecureToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired - dapat trigger redirect ke login
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
