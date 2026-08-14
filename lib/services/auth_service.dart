import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  AuthService(this._dioClient, this._secureStorage);

  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      // Backend wraps payloads in an envelope: { "data": { ... } }.
      // LoginResponse = { accessToken, refreshToken, expiresIn, user }.
      final body = (response.data['data'] ?? response.data) as Map<String, dynamic>;

      final token = body['accessToken'] as String;
      final refreshToken = body['refreshToken'] as String;
      final user = _userFromBackend(body['user'] as Map<String, dynamic>);

      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
      await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));

      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(AuthFailure(message: 'Erreur de connexion: ${e.toString()}'));
    }
  }

  /// Changes the signed-in user's own password. The current one is required —
  /// an access token alone must never be enough to take over the account.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur: ${e.toString()}'));
    }
  }

  /// Maps the backend UserDto onto [UserModel]. The backend sends the role in
  /// PascalCase ("Admin"/"Commercial"); the app compares it lowercase, so we
  /// normalize here before deserializing (and before caching it).
  UserModel _userFromBackend(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final role = normalized['role'];
    if (role is String) normalized['role'] = role.toLowerCase();
    return UserModel.fromJson(normalized);
  }

  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read(key: AppConstants.userKey);
      if (userData == null) {
        return const Left(AuthFailure(message: 'Utilisateur non connecté'));
      }
      final user = UserModel.fromJson(jsonDecode(userData));
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userKey);
  }
}
