import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/erp_ref_model.dart';

/// Divalto lookups feeding the dynamic-form autocompletes.
///
/// Both searches run SERVER-side and are capped: 2 669 clients and 791 articles
/// must never travel to a phone on a keystroke. Replaces the old ClientService,
/// which proxied a stubbed Divalto HTTP client and returned fake names.
class LookupService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  LookupService(this._dioClient, this._networkInfo);

  /// Minimum characters before the API is worth calling (the backend enforces it too).
  static const int minQueryLength = 2;

  Future<Either<Failure, List<ErpRef>>> searchClients(String query, {int limit = 20}) =>
      _search(
        ApiConstants.clientSearch,
        query,
        limit,
        ErpRef.fromClientJson,
      );

  Future<Either<Failure, List<ErpRef>>> searchArticles(String query, {int limit = 20}) =>
      _search(
        ApiConstants.articleSearch,
        query,
        limit,
        ErpRef.fromArticleJson,
      );

  /// Dispatches on the schema's `source` value — the fronts never hard-code which
  /// field talks to which table. Only the SEARCHABLE sources are routed here;
  /// `technicien` is a closed list fetched whole (see [fetchTechniciens]).
  Future<Either<Failure, List<ErpRef>>> searchBySource(String source, String query,
      {int limit = 20}) {
    switch (source) {
      case 'client':
        return searchClients(query, limit: limit);
      case 'article':
        return searchArticles(query, limit: limit);
      default:
        return Future.value(const Right(<ErpRef>[]));
    }
  }

  /// Technicians registered in the application (`source: 'technicien'`).
  ///
  /// Unlike clients and articles this is not a search: a handful of accounts, so
  /// the whole list is fetched once when the form opens and rendered as an ordinary
  /// dropdown. An empty list is a valid answer — no technician created yet — and
  /// the form says so rather than showing an empty picker.
  Future<Either<Failure, List<ErpRef>>> fetchTechniciens() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(ApiConstants.techniciens);
      // Envelope: { "data": [ ... ] }
      final list = (response.data['data'] ?? response.data) as List;
      return Right(list
          .map((e) => ErpRef.fromTechnicienJson(e as Map<String, dynamic>))
          .where((t) => t.label.isNotEmpty)
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, List<ErpRef>>> _search(
    String path,
    String query,
    int limit,
    ErpRef Function(Map<String, dynamic>) parse,
  ) async {
    final q = query.trim();
    if (q.length < minQueryLength) return const Right(<ErpRef>[]);
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        path,
        queryParameters: {'q': q, 'limit': limit},
        // Délai COURT, propre à la recherche : 8 secondes au lieu des 30 du
        // client global. Une suggestion de produit qui met une demi-minute n'a
        // plus d'intérêt — le commercial a fini de taper depuis longtemps et
        // croit l'application figée. Passé ce délai, il lit « Recherche
        // indisponible » et sait à quoi s'en tenir.
        //
        // Les SOUMISSIONS gardent leurs 30 secondes : abandonner l'envoi d'une
        // demande sur un réseau lent ferait perdre une saisie entière.
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      // Envelope: { "data": [ ... ] }
      final list = (response.data['data'] ?? response.data) as List;
      return Right(list.map((e) => parse(e as Map<String, dynamic>)).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }
}
