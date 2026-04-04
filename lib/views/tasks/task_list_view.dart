import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(taskListProvider.notifier).loadTasks(refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Tâches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.taskForm),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
      body: SafeArea(
        child: state.isLoading && state.tasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(taskListProvider.notifier).loadTasks(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          task.nomClient,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              task.numero ?? '',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: _buildStatusBadge(task.statut),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color color;
    String label;

    switch (statut) {
      case AppConstants.taskStatusEnCours:
        color = AppColors.taskEnCours;
        label = 'En cours';
      case AppConstants.taskStatusRealisee:
        color = AppColors.taskRealisee;
        label = 'Réalisée';
      case AppConstants.taskStatusAnnulee:
        color = AppColors.taskAnnulee;
        label = 'Annulée';
      default:
        color = Colors.grey;
        label = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
