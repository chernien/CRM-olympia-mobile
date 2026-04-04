import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../models/task_model.dart';
import '../task_service.dart';
import 'mock_data.dart';

class MockTaskService extends TaskService {
  final List<TaskModel> _tasks = List.from(MockData.tasks);
  int _counter = MockData.tasks.length;

  MockTaskService(DioClient dioClient) : super(dioClient);

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks({
    int page = 1,
    int pageSize = 20,
    String? statut,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var filtered = _tasks.toList();
    if (statut != null) {
      filtered = filtered.where((t) => t.statut == statut).toList();
    }

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const Right([]);

    final end = start + pageSize;
    return Right(filtered.sublist(start, end.clamp(0, filtered.length)));
  }

  @override
  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _counter++;
    final newTask = TaskModel(
      id: 'tsk-${_counter.toString().padLeft(3, '0')}',
      numero: 'T-2026-${_counter.toString().padLeft(4, '0')}',
      codeClient: task.codeClient,
      nomClient: task.nomClient,
      adresse: task.adresse,
      description: task.description,
      datePrevue: task.datePrevue,
      priorite: task.priorite,
      statut: 'en_cours_traitement',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    return Right(newTask);
  }

  @override
  Future<Either<Failure, TaskModel>> updateTaskStatus(
    String taskId,
    String statut,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      return const Left(ServerFailure(message: 'Tâche introuvable', statusCode: 404));
    }

    final old = _tasks[index];
    final updated = TaskModel(
      id: old.id,
      numero: old.numero,
      codeClient: old.codeClient,
      nomClient: old.nomClient,
      adresse: old.adresse,
      description: old.description,
      datePrevue: old.datePrevue,
      priorite: old.priorite,
      statut: statut,
      pieceJointeUrl: old.pieceJointeUrl,
      commercialId: old.commercialId,
      commercialNom: old.commercialNom,
      createdAt: old.createdAt,
    );
    _tasks[index] = updated;
    return Right(updated);
  }
}
