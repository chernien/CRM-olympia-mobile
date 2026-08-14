import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/demande_model.dart';
import '../models/workflow_model.dart';

class DemandeService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  DemandeService(this._dioClient, this._networkInfo);

  /// Workflow schemas for every implemented type — feeds the dynamic form renderer.
  Future<Either<Failure, List<WorkflowDefinition>>> getDefinitions() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get('${ApiConstants.demandes}/definitions');
      final list = (response.data['data'] as List)
          .map((e) => WorkflowDefinition.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// Workflow schema of a single type (its phases and fields).
  Future<Either<Failure, WorkflowDefinition>> getDefinition(int typeDemande) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response =
          await _dioClient.get('${ApiConstants.demandes}/definitions/$typeDemande');
      return Right(WorkflowDefinition.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  /// The demandes waiting for the caller's role to act (the "à traiter" inbox).
  Future<Either<Failure, List<DemandeModel>>> getInbox({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        '${ApiConstants.demandes}/inbox',
        queryParameters: {'page': page, 'pageSize': pageSize},
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

  /// Creates a demande = submits its first phase. `fields` is the bare phase-1
  /// field map (the backend keys it under the phase itself); files go in `piecesJointes`.
  Future<Either<Failure, DemandeModel>> createFromPhase1({
    required int typeDemande,
    String? nomClient,
    String? codeClient,
    Map<String, dynamic> fields = const {},
    List<String>? piecesJointes,
    String? commentaire,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.post(
        ApiConstants.demandes,
        data: {
          'typeDemande': typeDemande,
          'nomClient': nomClient,
          'codeClient': codeClient,
          'formData': fields,
          'piecesJointes': piecesJointes,
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

  /// Submits the current phase and advances the workflow.
  Future<Either<Failure, DemandeModel>> submitPhase(
    String demandeId, {
    Map<String, dynamic> fields = const {},
    List<String>? piecesJointes,
    String? commentaire,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.post(
        '${ApiConstants.demandes}/$demandeId/phase',
        data: {
          'fields': fields,
          'piecesJointes': piecesJointes,
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
