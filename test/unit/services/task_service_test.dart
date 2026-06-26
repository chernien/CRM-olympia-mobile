import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_app/services/mock/mock_task_service.dart';
import 'package:olympia_app/core/errors/failures.dart';
import 'package:olympia_app/core/network/network_info.dart';
import 'package:olympia_app/core/network/dio_client.dart';

class _AlwaysConnected implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _StubDioClient implements DioClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockTaskService service;

  setUp(() {
    service = MockTaskService(_StubDioClient(), _AlwaysConnected());
  });

  group('getTaskById', () {
    test('returns task for existing id', () async {
      final tasks = await service.getTasks();
      final firstId = tasks.getOrElse(() => []).first.id;

      final result = await service.getTaskById(firstId!);
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (task) {
        expect(task.id, firstId);
      });
    });

    test('returns ServerFailure for missing id', () async {
      final result = await service.getTaskById('not-a-real-id');
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
      }, (_) => fail('Expected Left'));
    });
  });

  group('deleteTask', () {
    test('removes task from list', () async {
      final tasks = await service.getTasks();
      final firstId = tasks.getOrElse(() => []).first.id;

      final deleteResult = await service.deleteTask(firstId!);
      expect(deleteResult.isRight(), isTrue);

      final listResult = await service.getTasks();
      listResult.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.any((t) => t.id == firstId), isFalse),
      );
    });

    test('returns ServerFailure for missing id', () async {
      final result = await service.deleteTask('ghost-id');
      expect(result.isLeft(), isTrue);
    });
  });
}
