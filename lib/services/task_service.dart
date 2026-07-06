import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/task_model.dart';

class TaskService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  TaskService(this._dioClient, this._networkInfo);

  Future<Either<Failure, List<TaskModel>>> getTasks({
    int page = 1,
    int pageSize = 20,
    String? statut,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.taches,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'statut': statut,
        },
      );
      final tasks = (response.data['data'] as List)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      // CreateTacheRequest: server sets statut (realisee), numero, commercialId
      // and the date (= creation time). The task must reference a task objective.
      final response = await _dioClient.post(
        ApiConstants.taches,
        data: {
          'codeClient': task.codeClient,
          'nomClient': task.nomClient,
          'adresse': task.adresse,
          'description': task.description,
          'objectifId': task.objectifId,
          'pieceJointeUrl': task.pieceJointeUrl,
        },
      );
      return Right(TaskModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, TaskModel>> updateTaskStatus(
    String taskId,
    String statut,
  ) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.put(
        '${ApiConstants.taches}/$taskId/statut',
        data: {'statut': statut},
      );
      return Right(TaskModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, TaskModel>> getTaskById(String id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get('${ApiConstants.taches}/$id');
      return Right(TaskModel.fromJson(_unwrap(response.data)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, void>> deleteTask(String id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dioClient.delete('${ApiConstants.taches}/$id');
      return const Right(null);
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
