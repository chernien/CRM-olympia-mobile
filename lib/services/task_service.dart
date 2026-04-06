import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskService {
  final DioClient _dioClient;

  TaskService(this._dioClient);

  Future<Either<Failure, List<TaskModel>>> getTasks({
    int page = 1,
    int pageSize = 20,
    String? statut,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.taches,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'statut': ?statut,
        },
      );
      final tasks = (response.data['data'] as List)
          .map((e) => TaskModel.fromJson(e))
          .toList();
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.taches,
        data: task.toJson(),
      );
      return Right(TaskModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, TaskModel>> updateTaskStatus(
    String taskId,
    String statut,
  ) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.taches}/$taskId/statut',
        data: {'statut': statut},
      );
      return Right(TaskModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
