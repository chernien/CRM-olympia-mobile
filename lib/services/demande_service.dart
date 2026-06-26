import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/demande_model.dart';

class DemandeService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  DemandeService(this._dioClient, this._networkInfo);

  Future<Either<Failure, List<DemandeModel>>> getDemandes({
    int page = 1,
    int pageSize = 20,
    int? typeDemande,
    String? statut,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.demandes,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'typeDemande': typeDemande,
          'statut': statut,
        },
      );
      final demandes = (response.data['data'] as List)
          .map((e) => DemandeModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(demandes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, DemandeModel>> getDemandeById(String id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get('${ApiConstants.demandes}/$id');
      return Right(DemandeModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, DemandeModel>> createDemande(DemandeModel demande) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.post(
        ApiConstants.demandes,
        data: demande.toJson(),
      );
      return Right(DemandeModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, DemandeModel>> updateDemandeStatus(
    String demandeId,
    String statut, {
    String? commentaire,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.put(
        '${ApiConstants.demandes}/$demandeId/statut',
        data: {
          'statut': statut,
          'commentaire': commentaire,
        },
      );
      return Right(DemandeModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// Unwraps the single-resource envelope `{ "data": { ... } }`.
  Map<String, dynamic> _unwrap(dynamic data) =>
      ((data is Map && data['data'] is Map) ? data['data'] : data)
          as Map<String, dynamic>;
}
