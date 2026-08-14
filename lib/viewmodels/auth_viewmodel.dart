import 'dart:async';
import 'package:dartz/dartz.dart';
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

    // Lie cet appareil au compte : sans jeton enregistré, aucun push ne peut
    // l'atteindre. Volontairement non bloquant — l'échec n'empêche pas d'entrer.
    if (state.isAuthenticated) {
      unawaited(ref.read(pushServiceProvider).registerDevice());
    }
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

      // Réenregistrement du jeton FCM à CHAQUE ouverture avec session restaurée,
      // pas seulement après une connexion.
      //
      // Une réinstallation ou une mise à jour de l'application génère un jeton
      // NEUF. Or l'utilisateur déjà connecté ne repasse pas par l'écran de
      // connexion : le nouveau jeton n'était donc jamais transmis, et le serveur
      // continuait d'écrire vers des jetons morts. Symptôme observé : l'envoi
      // réussit côté serveur, le téléphone ne reçoit rien.
      //
      // Non bloquant, et sans effet de bord : le backend fait un upsert sur le
      // jeton, réenregistrer le même ne crée pas de doublon.
      if (state.isAuthenticated) {
        unawaited(ref.read(pushServiceProvider).registerDevice());
      }
    } else {
      // Ensure stale in-memory state is cleared.
      await logout();
    }
  }

  /// Changes the signed-in user's own password (current password required).
  /// Returns the raw result so the UI can show a precise server-side message.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final authService = ref.read(authServiceProvider);
    return authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    // Le jeton doit partir AVANT la purge des identifiants : l'appel DELETE est
    // authentifié, et un jeton laissé en base enverrait les notifications du
    // compte suivant sur ce téléphone au précédent utilisateur.
    await ref.read(pushServiceProvider).unregisterDevice();
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AuthState();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
