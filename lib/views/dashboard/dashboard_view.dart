import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    // Custom Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            Text(
                              'Olympia User',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Period Selector (Custom Pill Style)
                    _buildPeriodSelector(state),
                    const SizedBox(height: 32),

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
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'En cours',
                            value: '${state.statsTaches?.enCoursDeTraitement ?? 0}',
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // CA Chart
                    Text(
                      'Chiffre d\'Affaires',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const CAChartWidget(),
                    const SizedBox(height: 100), // Padding for floating nav bar
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _periodButton(
              title: 'Mensuel',
              isSelected: state.selectedPeriod == PeriodType.mensuel,
              onTap: () => ref.read(dashboardProvider.notifier).selectPeriod(PeriodType.mensuel),
            ),
          ),
          Expanded(
            child: _periodButton(
              title: 'Trimestriel',
              isSelected: state.selectedPeriod == PeriodType.trimestriel,
              onTap: () => ref.read(dashboardProvider.notifier).selectPeriod(PeriodType.trimestriel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
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