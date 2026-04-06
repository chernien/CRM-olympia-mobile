import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
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
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed App Bar
                  Padding(
                    padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 20.h, bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clear, unboxed Logo
                        SvgPicture.asset(
                          'assets/images/OLY-svg.svg',
                          height: 52.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10.r,
                                offset: Offset(0, 4.h),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24.sp),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        children: [
                          // Welcome Text (moved inside scroll)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenue',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                              ),
                              Text(
                                'Olympia User',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                      fontSize: 24.sp,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                    // Period Selector (Custom Pill Style)
                    _buildPeriodSelector(state),
                    SizedBox(height: 32.h),

                    // Stats cards grid
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites ce mois',
                            value: '${state.statsVisites?.moisEnCours ?? 0}',
                            icon: Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches ce mois',
                            value: '${state.statsTaches?.moisEnCours ?? 0}',
                            icon: Icons.task_alt,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites trim.',
                            value: '${state.statsVisites?.trimestreEnCours ?? 0}',
                            icon: Icons.calendar_month,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches trim.',
                            value: '${state.statsTaches?.trimestreEnCours ?? 0}',
                            icon: Icons.task,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // CA Chart
                    Text(
                      'Chiffre d\'Affaires',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    const CAChartWidget(),
                          SizedBox(height: 100.h), // Padding for floating nav bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(DashboardState state) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
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
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}