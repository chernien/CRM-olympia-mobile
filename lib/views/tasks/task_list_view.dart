import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../shared/widgets/status_badge.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  String _activeFilter = 'tous';

  static const _filters = [
    ('tous', 'Toutes'),
    (AppConstants.taskStatusEnCours, 'En cours'),
    (AppConstants.taskStatusRealisee, 'Réalisées'),
    (AppConstants.taskStatusAnnulee, 'Annulées'),
  ];

  List<TaskModel> _filtered(List<TaskModel> all) {
    if (_activeFilter == 'tous') return all;
    return all.where((t) => t.statut == _activeFilter).toList();
  }

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
    final filtered = _filtered(state.tasks);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes Tâches', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        actions: [
          GestureDetector(
            onTap: () => context.goNamed(RouteNames.taskForm),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 20.sp, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.tasks.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(taskListProvider.notifier).loadTasks(refresh: true),
                child: ListView(
                  padding: EdgeInsets.all(16.r),
                  children: [
                    _buildHeader(state.tasks.length),
                    SizedBox(height: 16.h),
                    _buildFilterChips(),
                    SizedBox(height: 14.h),
                    if (filtered.isEmpty) _buildEmptyState(),
                    ...filtered.map(_buildTaskCard),
                    if (state.isLoading && filtered.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(child: CircularProgressIndicator.adaptive()),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final (value, label) = _filters[index];
          final isActive = _activeFilter == value;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.secondary.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tâches à suivre', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 4.h),
                Text('$count tâches en cours', style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final dueDate = '${task.datePrevue.day.toString().padLeft(2, '0')}/${task.datePrevue.month.toString().padLeft(2, '0')}/${task.datePrevue.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.nomClient,
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(statut: task.statut),
              ],
            ),
            SizedBox(height: 8.h),
            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
            if (task.adresse != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.textSecondary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(task.adresse!, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetaChip(Icons.calendar_month_outlined, dueDate),
                _buildPriorityChip(task.priorite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final color = switch (priority) {
      AppConstants.priorityHaute => AppColors.secondary,
      AppConstants.priorityUrgente => AppColors.secondary,
      _ => AppColors.primary,
    };
    final label = switch (priority) {
      AppConstants.priorityHaute => 'Haute',
      AppConstants.priorityUrgente => 'Urgente',
      _ => 'Normale',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt_rounded, size: 48.sp, color: AppColors.primary),
          SizedBox(height: 16.h),
          Text('Aucune tâche disponible', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Tirez vers le bas pour actualiser ou ajoutez une nouvelle tâche.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
