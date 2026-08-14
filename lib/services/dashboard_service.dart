import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/ca_categorie.dart';
import '../models/dashboard_model.dart';
import '../models/objectif_progress.dart';

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

/// Talks to the backend's single rich endpoint `GET /dashboard/stats?periode=`.
///
/// The backend returns everything for a period in one payload
/// ([DashboardStatsDto]). We keep the four public getters so the ViewModel is
/// unchanged, fanning them out onto two cached calls (`month` + `quarter`),
/// deduplicated so the ViewModel's parallel calls trigger at most two requests.
class DashboardService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  DashboardService(this._dioClient, this._networkInfo);

  // Indexés par clé de période ('month' | 'quarter' | 'all') plutôt qu'une paire de
  // champs par période : ajouter « Global » ne demande plus de toucher au cache,
  // à la déduplication et à l'écriture en trois endroits séparables.
  final _caches = <String, _Cached<Map<String, dynamic>>>{};
  final _inFlight = <String, Future<Either<Failure, Map<String, dynamic>>>>{};

  _Cached<Map<String, dynamic>> _cacheFor(String periode) =>
      _caches.putIfAbsent(periode, () => _Cached<Map<String, dynamic>>());

  /// Bust all caches (e.g. on pull-to-refresh).
  void clearCache() {
    for (final c in _caches.values) {
      c.clear();
    }
  }

  // ─── Public getters (stable API for the ViewModel) ───────────────

  Future<Either<Failure, CAData>> getCaMensuel({int? mois, int? annee}) async {
    final res = await _fetch('month');
    return res.map(_caData);
  }

  Future<Either<Failure, CAData>> getCaTrimestriel(
      {int? trimestre, int? annee}) async {
    final res = await _fetch('quarter');
    return res.map(_caData);
  }

  /// CA « Global » : tout depuis le début, toutes périodes confondues.
  Future<Either<Failure, CAData>> getCaGlobal() async {
    final res = await _fetch('all');
    return res.map(_caData);
  }

  Future<Either<Failure, StatsVisites>> getStatsVisites() async {
    final month = await _fetch('month');
    if (month.isLeft()) return month.map((_) => throw StateError('x'));
    final quarter = await _fetch('quarter');
    final m = month.getOrElse(() => const {});
    return quarter.map((q) => StatsVisites(
          moisEnCours: _toInt(m['visites']),
          trimestreEnCours: _toInt(q['visites']),
        ));
  }

  Future<Either<Failure, StatsTaches>> getStatsTaches() async {
    final month = await _fetch('month');
    if (month.isLeft()) return month.map((_) => throw StateError('x'));
    final quarter = await _fetch('quarter');
    final m = month.getOrElse(() => const {});
    return quarter.map((q) => StatsTaches(
          moisEnCours: _toInt(m['taches']),
          trimestreEnCours: _toInt(q['taches']),
          enCoursDeTraitement: _toInt(m['tachesEnCours']),
        ));
  }

  /// CA split by article category (Intérieur / Extérieur / Olybat), resolved
  /// server-side through Divalto: ENT → MOUV → ART → T012.
  Future<Either<Failure, CaCategories>> getCaCategories(String periode) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.dashboardCaCategories,
        queryParameters: {'periode': periode},
      );
      final data =
          (response.data['data'] ?? response.data) as Map<String, dynamic>;
      return Right(CaCategories.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// CA objectives (admin-set) with the current commercial's attainment (%).
  Future<Either<Failure, List<ObjectifProgress>>> getObjectifsProgress() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(ApiConstants.objectifsProgress);
      final list = (response.data['data'] ?? response.data) as List;
      return Right(list
          .map((e) => ObjectifProgress.fromJson(e as Map<String, dynamic>))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// Marks an objective's congratulations as shown for the current user.
  /// Server-side and idempotent — the popup never comes back, on any device.
  Future<void> markObjectifCelebrated(String objectifId) async {
    try {
      await _dioClient.post(
        ApiConstants.objectifCelebrate.replaceFirst('{id}', objectifId),
      );
    } catch (_) {
      // Non-fatal: worst case the popup shows once more; never block the UI.
    }
  }

  // ─── Core fetch (cached + deduped per period) ────────────────────

  Future<Either<Failure, Map<String, dynamic>>> _fetch(String periode) async {
    final cache = _cacheFor(periode);
    if (cache.isValid) return Right(cache.value!);

    // Deduplicate concurrent requests for the same period.
    final existing = _inFlight[periode];
    if (existing != null) return existing;

    final future = _doFetch(periode);
    _inFlight[periode] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(periode);
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _doFetch(String periode) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.dashboardStats,
        queryParameters: {'periode': periode},
      );
      // Envelope: { "data": { ... DashboardStatsDto ... } }
      final data =
          (response.data['data'] ?? response.data) as Map<String, dynamic>;
      _cacheFor(periode).store(data);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  // ─── Mappers ─────────────────────────────────────────────────────

  CAData _caData(Map<String, dynamic> j) => CAData(
        total: _toDouble(j['ca']),
        intern: _toDouble(j['caIntern']),
        extern: _toDouble(j['caExtern']),
        olybat: _toDouble(j['caOlybat']),
        points: ((j['caPoints'] as List?) ?? const [])
            .map((p) => CAPoint(
                  label: (p['label'] ?? '') as String,
                  value: _toDouble(p['value']),
                ))
            .toList(),
      );

  static double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
}
