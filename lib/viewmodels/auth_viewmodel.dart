import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/injection.dart';
import '../core/errors/failures.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final Failure? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    Failure? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  AuthService get _authService => getIt<AuthService>();

  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.login(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      ),
    );
  }

  Future<void> checkAuth() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final result = await _authService.getCurrentUser();
      result.fold(
        (_) => state = const AuthState(),
        (user) => state = AuthState(user: user, isAuthenticated: true),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
