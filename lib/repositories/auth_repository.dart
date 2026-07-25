import '../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  /// Authenticate user via Laravel middleware
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final String token = data['token'] as String;
      final Map<String, dynamic> userJson = data['user'] as Map<String, dynamic>;
      final UserModel user = UserModel.fromJson(userJson);

      // Save token and user info locally
      final storage = await LocalStorageService.getInstance();
      await storage.saveToken(token);
      await storage.saveUser(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify current session (Auto Login verification)
  Future<UserModel?> checkSession() async {
    try {
      final storage = await LocalStorageService.getInstance();
      if (!storage.isLoggedIn()) return null;

      // Call Laravel profile endpoint to verify token validity
      final response = await _dioClient.dio.get('/me');
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final Map<String, dynamic> userJson = data['user'] as Map<String, dynamic>;
      final UserModel user = UserModel.fromJson(userJson);

      // Update cached user details just in case
      await storage.saveUser(user);
      return user;
    } catch (e) {
      // If server returns error, clear credentials
      final storage = await LocalStorageService.getInstance();
      await storage.clearAuth();
      return null;
    }
  }

  /// Revoke session & logout user
  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/logout');
    } catch (_) {
      // Even if network fails, we proceed with local logout
    } finally {
      final storage = await LocalStorageService.getInstance();
      await storage.clearAuth();
    }
  }
}
