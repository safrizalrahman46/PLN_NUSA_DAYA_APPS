import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
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
    final user = await _api.login(username, password);
    await _tokenStorage.saveToken(user.token);
    await _hiveService.settingsBox.put('current_user', user.toJson());
    await _hiveService.settingsBox.put(_rememberMeKey, rememberMe);
    return user;
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

  Future<void> logout() async {
    await _api.logout();
    await _tokenStorage.clear();
    await _hiveService.settingsBox.delete('current_user');
  }
}
