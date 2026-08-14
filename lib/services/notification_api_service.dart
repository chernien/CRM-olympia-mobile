import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/notification_model.dart';

/// Accès REST aux notifications.
///
/// C'est LE contrat : FCM ne fait que réveiller l'application, qui vient ensuite
/// chercher ici le contenu réel. Si le push n'arrive jamais (Firebase pas encore
/// configuré, appareil hors ligne…), l'écran Notifications reste correct.
class NotificationApiService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  NotificationApiService(this._dioClient, this._networkInfo);

  Future<Either<Failure, NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 30,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return Right(
        NotificationPage.fromJson(response.data as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// Marque une notification comme lue. Renvoie le nombre de non-lues restantes.
  Future<Either<Failure, int>> markRead(String id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.post(
        ApiConstants.notificationLu.replaceFirst('{id}', id),
      );
      final body = (response.data['data'] ?? response.data) as Map<String, dynamic>;
      return Right(body['nonLues'] as int? ?? 0);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur: $e'));
    }
  }

  Future<Either<Failure, void>> markAllRead() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dioClient.post(ApiConstants.notificationsToutLu);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur: $e'));
    }
  }

  /// Enregistre le jeton FCM de cet appareil (à la connexion). Idempotent.
  Future<Either<Failure, void>> registerDevice({
    required String token,
    required String plateforme,
  }) async {
    try {
      await _dioClient.post(
        ApiConstants.notificationAppareils,
        data: {'token': token, 'plateforme': plateforme},
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur: $e'));
    }
  }

  /// Supprime le jeton de cet appareil (à la déconnexion) — sinon le commercial
  /// suivant sur le même téléphone recevrait les notifications du précédent.
  Future<Either<Failure, void>> unregisterDevice(String token) async {
    try {
      await _dioClient.delete(
        ApiConstants.notificationAppareils,
        data: {'token': token},
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur: $e'));
    }
  }
}
