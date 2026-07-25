import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Save API auth token
  Future<bool> saveToken(String token) async {
    return await _preferences!.setString(_keyToken, token);
  }

  /// Retrieve API auth token
  String? getToken() {
    return _preferences!.getString(_keyToken);
  }

  /// Delete API auth token
  Future<bool> deleteToken() async {
    return await _preferences!.remove(_keyToken);
  }

  /// Save User Profile JSON
  Future<bool> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    return await _preferences!.setString(_keyUser, userJson);
  }

  /// Retrieve User Profile Model
  UserModel? getUser() {
    final userJson = _preferences!.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Delete User Profile
  Future<bool> deleteUser() async {
    return await _preferences!.remove(_keyUser);
  }

  /// Clear all credentials (Logout)
  Future<void> clearAuth() async {
    await deleteToken();
    await deleteUser();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null && getUser() != null;
  }
}
