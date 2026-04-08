import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/OLY-svg.svg',
          height: 42.h,
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
                child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22.sp),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  children: [
                    _buildWelcomeCard(),
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
                            value: '${state.statsVisites?.moisEnCours ?? 0}',
                            icon: Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches ce mois',
                            value: '${state.statsTaches?.moisEnCours ?? 0}',
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
                            value: '${state.statsVisites?.trimestreEnCours ?? 0}',
                            icon: Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches trim.',
                            value: '${state.statsTaches?.trimestreEnCours ?? 0}',
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
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.waving_hand_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
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
          _buildPeriodTab('Mensuel', state.selectedPeriod == PeriodType.mensuel, () {
            ref.read(dashboardProvider.notifier).selectPeriod(PeriodType.mensuel);
          }),
          _buildPeriodTab('Trimestriel', state.selectedPeriod == PeriodType.trimestriel, () {
            ref.read(dashboardProvider.notifier).selectPeriod(PeriodType.trimestriel);
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}