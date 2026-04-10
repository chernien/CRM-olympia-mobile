import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/ca_chart_widget.dart';
import 'widgets/stats_card_widget.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 38.h,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OLYMPIA',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
                Text(
                  'PAINTURE',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 4,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () => context.goNamed(RouteNames.notifications),
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isInitialLoad
            ? const _DashboardSkeleton()
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(dashboardProvider.notifier)
                    .loadDashboard(refresh: true),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  children: [
                    _buildWelcomeCard(),
                    // Error banner — shown over stale data during refresh
                    if (state.error != null) ...[
                      SizedBox(height: 12.h),
                      _ErrorBanner(
                        message: state.error!.message,
                        onRetry: () => ref
                            .read(dashboardProvider.notifier)
                            .loadDashboard(refresh: true),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Période'),
                    SizedBox(height: 10.h),
                    _buildPeriodSelector(state),
                    SizedBox(height: 22.h),
                    _buildSectionTitle('Activité'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites ce mois',
                            value:
                                '${state.statsVisites?.moisEnCours ?? 0}',
                            icon: Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches ce mois',
                            value:
                                '${state.statsTaches?.moisEnCours ?? 0}',
                            icon: Icons.task_alt_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites trim.',
                            value:
                                '${state.statsVisites?.trimestreEnCours ?? 0}',
                            icon: Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches trim.',
                            value:
                                '${state.statsTaches?.trimestreEnCours ?? 0}',
                            icon: Icons.assignment_turned_in_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    _buildSectionTitle('Chiffre d\'Affaires'),
                    SizedBox(height: 12.h),
                    const CAChartWidget(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = ref.watch(authProvider).user;
    final displayName = user?.fullName ?? 'Olympia User';
    final subtitle = [
      if (user?.role != null) user!.role == 'commercial' ? 'Commercial' : 'Admin',
      if (user?.zone != null) user!.zone!,
    ].join(' · ');

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.secondarySoft],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.white20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
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
                  'Bienvenue',
                  style: TextStyle(
                    color: AppColors.white90,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.white90,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPeriodSelector(DashboardState state) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildPeriodTab(
            'Mensuel',
            state.selectedPeriod == PeriodType.mensuel,
            () => ref
                .read(dashboardProvider.notifier)
                .selectPeriod(PeriodType.mensuel),
          ),
          _buildPeriodTab(
            'Trimestriel',
            state.selectedPeriod == PeriodType.trimestriel,
            () => ref
                .read(dashboardProvider.notifier)
                .selectPeriod(PeriodType.trimestriel),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Welcome card
          Container(
            height: 88.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          // Period selector
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          SizedBox(height: 22.h),
          // Stats row 1
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Stats row 2
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          // Chart area
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
