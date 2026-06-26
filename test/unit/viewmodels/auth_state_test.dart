import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_app/viewmodels/auth_viewmodel.dart';
import 'package:olympia_app/models/user_model.dart';
import 'package:olympia_app/core/errors/failures.dart';

void main() {
  final fakeUser = const UserModel(
    id: 'u1',
    email: 'test@olympia.com',
    nom: 'User',
    prenom: 'Test',
    role: 'commercial',
  );

  group('AuthState.copyWith', () {
    test('setting isAuthenticated to false clears user', () {
      final state = AuthState(user: fakeUser, isAuthenticated: true);
      final result = state.copyWith(isAuthenticated: false);
      expect(result.user, isNull);
      expect(result.isAuthenticated, isFalse);
    });

    test('copyWith without isAuthenticated preserves user', () {
      final state = AuthState(user: fakeUser, isAuthenticated: true);
      final result = state.copyWith(isLoading: true);
      expect(result.user, fakeUser);
      expect(result.isAuthenticated, isTrue);
    });

    test('setting isAuthenticated to true preserves passed user', () {
      const state = AuthState();
      final result = state.copyWith(
        user: fakeUser,
        isAuthenticated: true,
      );
      expect(result.user, fakeUser);
      expect(result.isAuthenticated, isTrue);
    });

    test('error is always replaced with passed value', () {
      const state = AuthState();
      const failure = ServerFailure(message: 'test error');
      final withError = state.copyWith(error: failure);
      expect(withError.error, failure);
      final cleared = withError.copyWith(isLoading: false);
      expect(cleared.error, isNull);
    });

    test('setting isAuthenticated to true without user preserves existing user', () {
      final state = AuthState(user: fakeUser, isAuthenticated: false);
      final result = state.copyWith(isAuthenticated: true);
      expect(result.user, fakeUser);
    });
  });
}
