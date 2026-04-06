import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/injection.dart';
import '../core/errors/failures.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskListState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final Failure? error;
  final bool hasMore;
  final int currentPage;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    Failure? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class TaskListNotifier extends Notifier<TaskListState> {
  TaskService get _taskService => getIt<TaskService>();

  @override
  TaskListState build() => const TaskListState();

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(currentPage: 1, tasks: [], hasMore: true);
    }
    if (!state.hasMore && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _taskService.getTasks(page: state.currentPage);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (tasks) => state = state.copyWith(
        isLoading: false,
        tasks: [...state.tasks, ...tasks],
        currentPage: state.currentPage + 1,
        hasMore: tasks.length >= 20,
      ),
    );
  }

  Future<bool> createTask(TaskModel task) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _taskService.createTask(task);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (newTask) {
        state = state.copyWith(
          isLoading: false,
          tasks: [newTask, ...state.tasks],
        );
        return true;
      },
    );
  }
}

final taskListProvider = NotifierProvider<TaskListNotifier, TaskListState>(TaskListNotifier.new);
