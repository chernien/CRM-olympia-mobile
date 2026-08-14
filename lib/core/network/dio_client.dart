import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;

  final Dio _refreshDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final FlutterSecureStorage _secureStorage;

  Completer<bool>? _refreshCompleter;

  /// Broadcast stream — emits one event whenever the session expires
  /// (i.e., token refresh failed and tokens have been cleared).
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_authInterceptor());

    if (AppConfig.enableNetworkLogs) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  Dio get dio => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await _secureStorage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token =
                await _secureStorage.read(key: AppConstants.tokenKey);
            error.requestOptions.headers['Authorization'] =
                'Bearer $token';
            final response =
                await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } else {
            await _secureStorage.delete(key: AppConstants.tokenKey);
            await _secureStorage
                .delete(key: AppConstants.refreshTokenKey);
            // Signal to all listeners (AuthNotifier) that the session ended.
            _sessionExpiredController.add(null);
          }
        }
        handler.next(error);
      },
    );
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken =
          await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      final response = await _refreshDio.post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        // Same envelope as /login: { "data": { accessToken, refreshToken, ... } }.
        final body =
            (response.data['data'] ?? response.data) as Map<String, dynamic>;
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: body['accessToken'] as String,
        );
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: body['refreshToken'] as String,
        );
        completer.complete(true);
        return true;
      }

      completer.complete(false);
      return false;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// [options] permet à un appel de resserrer ses propres délais sans toucher
  /// aux autres — la recherche type-ahead abandonne après 8 s là où une
  /// soumission de demande garde les 30 s du client. Facultatif : les appelants
  /// existants gardent exactement le comportement d'avant.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
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
      return await _dio.post(
          path, data: data, queryParameters: queryParameters);
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

  /// [data] is optional — pass it for soft-delete or batch-delete endpoints.
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
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

  void dispose() {
    _sessionExpiredController.close();
  }

  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
            message: 'Délai de connexion dépassé');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        // Backend error envelope: { "error": { "message", "code", ... } }.
        // Fall back to a flat "message" or a sane default.
        final data = error.response?.data;
        String? message;
        if (data is Map) {
          final err = data['error'];
          if (err is Map && err['message'] is String) {
            message = err['message'] as String;
          } else if (data['message'] is String) {
            message = data['message'] as String;
          }
        }
        return ServerException(
            message: message ?? 'Erreur serveur', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return const ServerException(
            message: 'Erreur de connexion au serveur');
      default:
        return const ServerException(
            message: 'Une erreur inattendue est survenue');
    }
  }
}
