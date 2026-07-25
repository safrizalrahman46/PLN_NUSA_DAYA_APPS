import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../dummy/dummy_data.dart';
import '../models/user_model.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Login ke backend lokal (POST /login)
  /// Backend mengembalikan:
  ///   { message, data: { id, name, username, role, unit_id, unit_name, token } }
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      final respData = response.data as Map<String, dynamic>;
      // Backend return: { message, data: { ..., token } }
      final rawUser = Map<String, dynamic>.from(
        (respData['data'] ?? respData['user'] ?? respData) as Map,
      );
      // Token bisa ada di dalam data atau di level atas
      if ((rawUser['token'] ?? '').toString().isEmpty) {
        rawUser['token'] = respData['token']?.toString() ?? '';
      }
      return UserModel.fromJson(rawUser);
    } on DioException catch (e) {
      // Fallback ke dummy data saat server tidak tersedia
      final user = DummyData.authenticate(username, password);
      if (user != null) return user;
      throw ApiException.fromDioException(
        e,
        fallbackMessage: 'Username atau password tidak valid',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } on DioException {
      return;
    }
  }

  Future<UserModel?> me() async {
    try {
      final response = await _dio.get('/me');
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException {
      return null;
    }
  }
}
