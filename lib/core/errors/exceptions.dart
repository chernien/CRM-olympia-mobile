class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Pas de connexion internet'});
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Erreur de cache local'});
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({required this.message, this.statusCode});
}
