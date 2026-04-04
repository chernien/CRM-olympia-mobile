import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/demande_model.dart';

class DemandeService {
  final DioClient _dioClient;

  DemandeService(this._dioClient);

  Future<Either<Failure, List<DemandeModel>>> getDemandes({
    int page = 1,
    int pageSize = 20,
    int? typeDemande,
    String? statut,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.demandes,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (typeDemande != null) 'typeDemande': typeDemande,
          if (statut != null) 'statut': statut,
        },
      );
      final demandes = (response.data['data'] as List)
          .map((e) => DemandeModel.fromJson(e))
          .toList();
      return Right(demandes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, DemandeModel>> getDemandeById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.demandes}/$id');
      return Right(DemandeModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, DemandeModel>> createDemande(DemandeModel demande) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.demandes,
        data: demande.toJson(),
      );
      return Right(DemandeModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, DemandeModel>> updateDemandeStatus(
    String demandeId,
    String statut, {
    String? commentaire,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.demandes}/$demandeId/statut',
        data: {
          'statut': statut,
          if (commentaire != null) 'commentaire': commentaire,
        },
      );
      return Right(DemandeModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
