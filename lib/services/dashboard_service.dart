import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

/// Simple in-memory cache entry with a configurable TTL.
class _Cached<T> {
  T? value;
  DateTime? fetchedAt;

  static const _ttl = Duration(minutes: 5);

  bool get isValid =>
      value != null &&
      fetchedAt != null &&
      DateTime.now().difference(fetchedAt!) < _ttl;

  void store(T v) {
    value = v;
    fetchedAt = DateTime.now();
  }

  void clear() {
    value = null;
    fetchedAt = null;
  }
}

class DashboardService {
  final DioClient _dioClient;

  DashboardService(this._dioClient);

  final _caMensuelCache     = _Cached<CAData>();
  final _caTrimestrielCache = _Cached<CAData>();
  final _statsVisitesCache  = _Cached<StatsVisites>();
  final _statsTachesCache   = _Cached<StatsTaches>();

  /// Bust all caches (e.g. on pull-to-refresh).
  void clearCache() {
    _caMensuelCache.clear();
    _caTrimestrielCache.clear();
    _statsVisitesCache.clear();
    _statsTachesCache.clear();
  }

  Future<Either<Failure, CAData>> getCaMensuel({int? mois, int? annee}) async {
    if (_caMensuelCache.isValid) return Right(_caMensuelCache.value!);
    try {
      final response = await _dioClient.get(
        ApiConstants.caMensuel,
        queryParameters: {
          'mois': ?mois,
          'annee': ?annee,
        },
      );
      final data = CAData.fromJson(response.data as Map<String, dynamic>);
      _caMensuelCache.store(data);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, CAData>> getCaTrimestriel(
      {int? trimestre, int? annee}) async {
    if (_caTrimestrielCache.isValid) return Right(_caTrimestrielCache.value!);
    try {
      final response = await _dioClient.get(
        ApiConstants.caTrimestriel,
        queryParameters: {
          'trimestre': ?trimestre,
          'annee': ?annee,
        },
      );
      final data = CAData.fromJson(response.data as Map<String, dynamic>);
      _caTrimestrielCache.store(data);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, StatsVisites>> getStatsVisites() async {
    if (_statsVisitesCache.isValid) return Right(_statsVisitesCache.value!);
    try {
      final response = await _dioClient.get(ApiConstants.statsVisites);
      final data =
          StatsVisites.fromJson(response.data as Map<String, dynamic>);
      _statsVisitesCache.store(data);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, StatsTaches>> getStatsTaches() async {
    if (_statsTachesCache.isValid) return Right(_statsTachesCache.value!);
    try {
      final response = await _dioClient.get(ApiConstants.statsTaches);
      final data =
          StatsTaches.fromJson(response.data as Map<String, dynamic>);
      _statsTachesCache.store(data);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }
}
