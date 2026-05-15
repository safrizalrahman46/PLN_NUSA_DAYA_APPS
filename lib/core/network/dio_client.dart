import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/token_storage.dart';
import '../constants/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient(ref.read(tokenStorageProvider)).dio;
});

class DioClient {
  DioClient(this._tokenStorage) {
    dio =
        Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                final token = await _tokenStorage.readToken();
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                handler.next(options);
              },
            ),
          );
  }

  final TokenStorage _tokenStorage;
  late final Dio dio;
}
