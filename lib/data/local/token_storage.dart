import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'hive_service.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.read(hiveServiceProvider)),
);

class TokenStorage {
  const TokenStorage(this._hive);

  final HiveService _hive;

  static const _tokenKey = 'auth_token';

  FlutterSecureStorage get _storage => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // Fallback ke Hive jika Secure Storage bermasalah di device Android
      await _hive.settingsBox.put('backup_$_tokenKey', token);
    }
  }

  Future<String?> readToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) return token;
    } catch (_) {}
    return _hive.settingsBox.get('backup_$_tokenKey') as String?;
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
    await _hive.settingsBox.delete('backup_$_tokenKey');
  }
}
