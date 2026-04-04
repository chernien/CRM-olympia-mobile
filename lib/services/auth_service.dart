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

      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final user = UserModel.fromJson(response.data['user']);

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
