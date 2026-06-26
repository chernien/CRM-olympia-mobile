import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/failures.dart';
import '../models/user_model.dart';
import '../core/config/service_providers.dart';

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
    final auth = isAuthenticated ?? this.isAuthenticated;
    return AuthState(
      // If explicitly logging out (auth set to false), clear the user.
      user: auth == false ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      // error is always reset on each transition (not preserved across copyWith calls)
      error: error,
      isAuthenticated: auth,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Subscribe to DioClient session-expiry events.
    // When token refresh fails in the interceptor, DioClient emits on
    // this stream. We reset auth state; RouterNotifier picks up the
    // state change and redirects to /login.
    final dioClient = ref.read(dioClientProvider);
    final subscription = dioClient.sessionExpired.listen((_) {
      state = const AuthState();
    });
    ref.onDispose(subscription.cancel);

    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final authService = ref.read(authServiceProvider);
    final result = await authService.login(email, password);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      ),
    );
  }

  Future<void> checkAuth() async {
    final authService = ref.read(authServiceProvider);
    final isAuth = await authService.isAuthenticated();
    if (isAuth) {
      final result = await authService.getCurrentUser();
      result.fold(
        (_) => state = const AuthState(),
        (user) => state = AuthState(user: user, isAuthenticated: true),
      );
    } else {
      // Ensure stale in-memory state is cleared.
      await logout();
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AuthState();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
