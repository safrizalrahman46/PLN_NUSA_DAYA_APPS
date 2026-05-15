import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../dummy/dummy_data.dart';
import '../models/user_model.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException {
      final user = DummyData.authenticate(username, password);
      if (user == null) {
        throw ApiException('Username atau password tidak valid');
      }
      return user;
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
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException {
      return null;
    }
  }
}
