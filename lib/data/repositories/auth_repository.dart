import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../dummy/dummy_data.dart';
import '../local/hive_service.dart';
import '../local/token_storage.dart';
import '../models/user_model.dart';
import '../remote/auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    AuthApi(ref.read(dioProvider)),
    ref.read(tokenStorageProvider),
    ref.read(hiveServiceProvider),
  );
});

class AuthRepository {
  AuthRepository(this._api, this._tokenStorage, this._hiveService);

  final AuthApi _api;
  final TokenStorage _tokenStorage;
  final HiveService _hiveService;

  static const _rememberMeKey = 'remember_me';

  Future<UserModel> login(
    String username,
    String password, {
    required bool rememberMe,
  }) async {
    // Clear stale cache and token before login attempt
    await _tokenStorage.clear();
    await _hiveService.settingsBox.delete('current_user');

    try {
      final user = await _api.login(username, password);
      await _tokenStorage.saveToken(user.token);
      await _hiveService.settingsBox.put('current_user', user.toJson());
      await _hiveService.settingsBox.put(_rememberMeKey, rememberMe);
      return user;
    } catch (e) {
      // Fallback ke autentikasi database lokal di Hive
      final localUser = await _authenticateLocally(username, password);
      if (localUser != null) {
        await _tokenStorage.saveToken(localUser.token);
        await _hiveService.settingsBox.put('current_user', localUser.toJson());
        await _hiveService.settingsBox.put(_rememberMeKey, rememberMe);
        return localUser;
      }
      rethrow;
    }
  }

  Future<UserModel?> _authenticateLocally(String username, String password) async {
    final cleanedUsername = username.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final cleanedPassword = password.trim();

    // 1. Cek dari DummyData (termasuk kal3/password yang sudah diseed)
    final dummyUser = DummyData.authenticate(cleanedUsername, cleanedPassword);
    if (dummyUser != null) return dummyUser;

    // 2. Cek dari daftar user kustom yang ditambahkan admin secara lokal di Hive
    final box = _hiveService.usersBox;
    if (box.containsKey(cleanedUsername)) {
      final savedPwd = _hiveService.settingsBox.get('pwd_$cleanedUsername');
      if (savedPwd == cleanedPassword) {
        final raw = box.get(cleanedUsername);
        if (raw is Map) {
          return UserModel.fromJson(Map<String, dynamic>.from(raw));
        }
      }
    }
    return null;
  }

  Future<bool> getRememberMe() async {
    return _hiveService.settingsBox.get(_rememberMeKey, defaultValue: true)
        as bool;
  }

  Future<UserModel?> getCurrentUser() async {
    final rememberMe = await getRememberMe();
    if (!rememberMe) {
      return null;
    }
    final raw = _hiveService.settingsBox.get('current_user');
    final token = await _tokenStorage.readToken();
    if (raw is Map && token != null && token.isNotEmpty) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(raw),
      ).copyWith(token: token);
    }
    return null;
  }

  Future<UserModel> updateCurrentUser(UserModel user) async {
    await _hiveService.settingsBox.put('current_user', user.toJson());
    // Juga update di usersBox jika user tersebut ada
    final box = _hiveService.usersBox;
    if (box.containsKey(user.username)) {
      await box.put(user.username, user.toJson());
    }
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _tokenStorage.clear();
    await _hiveService.settingsBox.delete('current_user');
  }
}
