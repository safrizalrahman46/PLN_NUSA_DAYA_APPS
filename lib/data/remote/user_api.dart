import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../models/user_model.dart';

class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  Future<List<UserModel>> getUsers({String? role, String? unitId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;
      if (unitId != null) queryParams['unit_id'] = unitId;

      final response = await _dio.get(
        '/users',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map(
            (json) => UserModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException('Gagal memproses data user dari server: $e');
    }
  }

  Future<UserModel> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
    String? unitId,
    String? unitName,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'name': name,
          'username': username,
          'password': password,
          'role': role,
          if (unitId != null) 'unit_id': unitId,
          if (unitName != null) 'unit_name': unitName,
        },
      );
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException('Gagal memproses data user dari server: $e');
    }
  }

  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? username,
    String? password,
    String? role,
    String? unitId,
    String? unitName,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$id',
        data: {
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (password != null) 'password': password,
          if (role != null) 'role': role,
          'unit_id': unitId,
          'unit_name': unitName,
        },
      );
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException('Gagal memproses data user dari server: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException('Gagal menghapus user: $e');
    }
  }

  Future<void> resetPassword(String id, String newPassword) async {
    try {
      await _dio.put(
        '/users/$id/reset-password',
        data: {'new_password': newPassword},
      );
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException('Gagal reset password: $e');
    }
  }
}
