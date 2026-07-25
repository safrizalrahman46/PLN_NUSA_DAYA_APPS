import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/error_handler.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient);
});

// Authentication state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Check if user has an active session (Auto-Login)
  Future<void> checkSession() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.checkSession();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(ErrorHandler.handle(e), stack);
    }
  }

  /// Perform login request
  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(username, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(ErrorHandler.handle(e), stack);
      return false;
    }
  }

  /// Perform logout request
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(ErrorHandler.handle(e), stack);
    }
  }
}

// Global Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
