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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).loadDashboard(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Period selector
                    _buildPeriodSelector(state),
                    const SizedBox(height: 16),

                    // CA Chart
                    const CAChartWidget(),
                    const SizedBox(height: 16),

                    // Stats cards row
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites ce mois',
                            value: '${state.statsVisites?.moisEnCours ?? 0}',
                            icon: Icons.location_on,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites trimestre',
                            value:
                                '${state.statsVisites?.trimestreEnCours ?? 0}',
                            icon: Icons.calendar_month,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'En cours',
                            value:
                                '${state.statsTaches?.enCoursDeTraitement ?? 0}',
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(DashboardState state) {
    return SegmentedButton<PeriodType>(
      segments: const [
        ButtonSegment(
          value: PeriodType.mensuel,
          label: Text('Mensuel'),
          icon: Icon(Icons.calendar_today),
        ),
        ButtonSegment(
          value: PeriodType.trimestriel,
          label: Text('Trimestriel'),
          icon: Icon(Icons.date_range),
        ),
      ],
      selected: {state.selectedPeriod},
      onSelectionChanged: (selected) {
        ref.read(dashboardProvider.notifier).selectPeriod(selected.first);
      },
    );
  }
}
