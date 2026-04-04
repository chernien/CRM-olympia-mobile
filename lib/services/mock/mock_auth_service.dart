import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../models/user_model.dart';
import '../auth_service.dart';
import 'mock_data.dart';

class MockAuthService extends AuthService {
  final FlutterSecureStorage _mockStorage;

  MockAuthService(DioClient dioClient, this._mockStorage)
      : super(dioClient, _mockStorage);

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final entry = MockData.users[email.toLowerCase()];
    if (entry == null || entry.$2 != password) {
      return const Left(
        AuthFailure(message: 'Email ou mot de passe incorrect', statusCode: 401),
      );
    }

    final user = entry.$1;

    await _mockStorage.write(key: AppConstants.tokenKey, value: 'mock-jwt-token-${user.id}');
    await _mockStorage.write(key: AppConstants.refreshTokenKey, value: 'mock-refresh-${user.id}');
    await _mockStorage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));

    return Right(user);
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final userData = await _mockStorage.read(key: AppConstants.userKey);
      if (userData == null) {
        return const Left(AuthFailure(message: 'Utilisateur non connecté'));
      }
      return Right(UserModel.fromJson(jsonDecode(userData)));
    } catch (e) {
      return const Left(AuthFailure(message: 'Erreur de cache'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _mockStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }

  @override
  Future<void> logout() async {
    await _mockStorage.delete(key: AppConstants.tokenKey);
    await _mockStorage.delete(key: AppConstants.refreshTokenKey);
    await _mockStorage.delete(key: AppConstants.userKey);
  }
}
