import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../shared/widgets/error_banner.dart';
import '../shared/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView>
    with AutomaticKeepAliveClientMixin {
  final _scroll = ScrollController();

  static const _filters = <(String?, String)>[
    (null, 'Toutes'),
    (AppConstants.taskStatusEnCours, 'En cours'),
    (AppConstants.taskStatusRealisee, 'Réalisées'),
    (AppConstants.taskStatusAnnulee, 'Annulées'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(taskListProvider.notifier).loadTasks(refresh: true),
    );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Read state without subscribing — guards against over-fire before
    // isLoading is set and prevents redundant page requests.
    final s = ref.read(taskListProvider);
    if (s.isLoading || !s.hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(taskListProvider.notifier).loadTasks();
    }
  }

  String _headerLabel(String? statut, int count) {
    final s = count != 1 ? 's' : '';
    return switch (statut) {
      AppConstants.taskStatusEnCours => '$count tâche$s en cours',
      AppConstants.taskStatusRealisee => '$count tâche$s réalisée$s',
      AppConstants.taskStatusAnnulee => '$count tâche$s annulée$s',
      _ => '$count tâche$s au total',
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mes tâches',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(RouteNames.taskForm),
            icon: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 20.sp, color: Colors.white),
            ),
            tooltip: 'Nouvelle tâche',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
              child: Column(
                children: [
                  if (!state.isInitialLoad) ...[
                    _buildHeader(state),
                    SizedBox(height: 16.h),
                  ],
                  _buildFilterChips(state.selectedStatut),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
            // Error banner — shown even when list has data (partial refresh fail)
            if (state.error != null)
              ErrorBanner(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                message: state.error!.message,
                onRetry: () =>
                    ref.read(taskListProvider.notifier).loadTasks(refresh: true),
              ),
            Expanded(
              child: state.isInitialLoad
                  ? const _TaskListSkeleton()
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(taskListProvider.notifier).loadTasks(refresh: true),
                      child: ListView.builder(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 100.r),
                        itemCount: state.tasks.isEmpty
                            ? 1
                            : state.tasks.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (state.tasks.isEmpty) {
                            return _buildEmptyState(state.selectedStatut);
                          }
                          if (i == state.tasks.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          return _TaskCard(
                            key: ValueKey(state.tasks[i].id),
                            task: state.tasks[i],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Computed only once in the header, not per-card-per-frame.
  Widget _buildHeader(TaskListState state) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGradientStart,
            AppColors.secondaryGradientStart,
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
              color: AppColors.white20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tâches à suivre',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _headerLabel(state.selectedStatut, state.tasks.length),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.white90,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(String? activeStatut) {
    // 44 dp row: the chips were ~30 dp tall, under the touch-target minimum.
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final (value, label) = _filters[index];
          final isActive = activeStatut == value;
          return Semantics(
            button: true,
            selected: isActive,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(taskListProvider.notifier).filterByStatut(value);
              },
              borderRadius: BorderRadius.circular(22.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.borderStrong,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isActive ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String? activeStatut) {
    final isFiltered = activeStatut != null;
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGhost,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.task_alt_rounded,
                size: 36.r, color: AppColors.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            isFiltered
                ? 'Aucune tâche dans cette catégorie'
                : 'Aucune tâche',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            isFiltered
                ? 'Essayez un autre filtre ou créez une nouvelle tâche.'
                : 'Enregistrez votre première visite client.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.goNamed(RouteNames.taskForm),
              icon: const Icon(Icons.add),
              label: const Text('Créer une tâche'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Extracted card widget ────────────────────────────────────────────────────
// A standalone StatelessWidget so Flutter's element tree can cache and skip
// rebuilds for unchanged items during list scroll.

class _TaskCard extends StatelessWidget {
  final TaskModel task;

  const _TaskCard({super.key, required this.task});

  String get _formattedDate {
    final d = task.createdAt;
    return d == null ? '—' : DateFormat('dd/MM/yyyy').format(d);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
        ),
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
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    StatusBadge(statut: task.statut),
                  ],
                ),
                if (task.objectifTitre != null &&
                    task.objectifTitre!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 5.w),
                      Text(
                        task.objectifTitre!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (task.adresse != null) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          task.adresse!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 14.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _MetaChip(
                    icon: Icons.calendar_month_outlined,
                    label: _formattedDate,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
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
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _TaskListSkeleton extends StatelessWidget {
  const _TaskListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 100.r),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 14.h),
          height: 130.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }
}

// Helper so TaskListState has consistent initial-load semantics
extension _TaskInitialLoad on TaskListState {
  bool get isInitialLoad => isLoading && tasks.isEmpty;
}
