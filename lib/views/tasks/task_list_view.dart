import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      appBar: AppBar(
        title: Text('Mes Tâches', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(RouteNames.taskForm),
            icon: Icon(Icons.add_box_rounded, size: 26.w, color: Theme.of(context).primaryColor),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.tasks.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(taskListProvider.notifier).loadTasks(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        title: Text(
                          task.nomClient,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6.h),
                            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp)),
                            SizedBox(height: 6.h),
                            Text(
                              task.numero ?? '',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}
