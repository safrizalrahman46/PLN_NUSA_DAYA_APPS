import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.rememberMe = true,
  });

  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;
  final bool rememberMe;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
    bool? rememberMe,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(authRepositoryProvider));
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final rememberMe = await _repository.getRememberMe();
    final user = await _repository.getCurrentUser();
    state = state.copyWith(
      isLoading: false,
      user: user,
      rememberMe: rememberMe,
      clearError: true,
    );
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final user = await _repository.login(
        username,
        password,
        rememberMe: state.rememberMe,
      );
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: ApiException.fromObject(error).message);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<void> updateUser(UserModel user) async {
    final saved = await _repository.updateCurrentUser(user);
    state = state.copyWith(user: saved);
  }
}
