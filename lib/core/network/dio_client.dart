import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            final token = await _secureStorage.read(key: AppConstants.tokenKey);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } else {
            // Clear tokens and redirect to login
            await _secureStorage.delete(key: AppConstants.tokenKey);
            await _secureStorage.delete(key: AppConstants.refreshTokenKey);
          }
        }
        handler.next(error);
      },
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: response.data['token'],
        );
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(message: 'Délai de connexion dépassé');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String? ??
            'Erreur serveur';
        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.connectionError:
        return const ServerException(message: 'Erreur de connexion au serveur');
      default:
        return const ServerException(message: 'Une erreur inattendue est survenue');
    }
  }
}
