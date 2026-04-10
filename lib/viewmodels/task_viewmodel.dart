import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/service_providers.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

// Sentinel: allows copyWith(selectedStatut: null) to explicitly clear the filter.
const _absent = Object();

class TaskListState {
  final List<TaskModel> tasks;

  /// True while the paginated list is being fetched.
  final bool isLoading;

  /// True while a create/updateStatus mutation is in-flight.
  /// Keeps the list UI responsive while the form submit button shows a spinner.
  final bool isSubmitting;

  final Failure? error;
  final bool hasMore;
  final int currentPage;
  final String? selectedStatut;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedStatut,
  });

  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? isSubmitting,
    Failure? error,
    bool? hasMore,
    int? currentPage,
    // Use _absent sentinel so callers can pass null to clear the filter.
    Object? selectedStatut = _absent,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedStatut: identical(selectedStatut, _absent)
          ? this.selectedStatut
          : selectedStatut as String?,
    );
  }
}

class TaskListNotifier extends Notifier<TaskListState> {
  // Resolved once in build() so tests can override via ProviderContainer.
  late final TaskService _taskService;

  @override
  TaskListState build() {
    _taskService = ref.read(taskServiceProvider);
    return const TaskListState();
  }

  Future<void> loadTasks({bool refresh = false}) async {
    if (!state.hasMore && !refresh) return;
    // Guard: skip if a fetch is already in progress (prevents scroll over-fire).
    if (state.isLoading) return;

    if (refresh) {
      state = TaskListState(
        isLoading: true,
        selectedStatut: state.selectedStatut,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _taskService.getTasks(
      page: state.currentPage,
      statut: state.selectedStatut,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (tasks) {
        // Avoid one extra empty request when the last page is exactly pageSize.
        final newTasks = [...state.tasks, ...tasks];
        state = state.copyWith(
          isLoading: false,
          tasks: newTasks,
          currentPage: state.currentPage + 1,
          hasMore: tasks.length == AppConstants.defaultPageSize && tasks.isNotEmpty,
        );
      },
    );
  }

  Future<bool> createTask(TaskModel task) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _taskService.createTask(task);

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure);
        return false;
      },
      (newTask) {
        state = state.copyWith(
          isSubmitting: false,
          tasks: [newTask, ...state.tasks],
        );
        return true;
      },
    );
  }

  Future<bool> updateTaskStatus(String taskId, String statut) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _taskService.updateTaskStatus(taskId, statut);

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure);
        return false;
      },
      (updatedTask) {
        final updated =
            state.tasks.map((t) => t.id == taskId ? updatedTask : t).toList();
        state = state.copyWith(isSubmitting: false, tasks: updated);
        return true;
      },
    );
  }

  /// Server-side filter — resets pagination and reloads from page 1.
  void filterByStatut(String? statut) {
    state = TaskListState(selectedStatut: statut);
    loadTasks(refresh: true);
  }
}

final taskListProvider =
    NotifierProvider<TaskListNotifier, TaskListState>(TaskListNotifier.new);
