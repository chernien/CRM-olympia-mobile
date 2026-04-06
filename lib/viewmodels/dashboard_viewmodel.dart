import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/injection.dart';
import '../core/errors/failures.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

enum PeriodType { mensuel, trimestriel }

class DashboardState {
  final CAData? caMensuel;
  final CAData? caTrimestriel;
  final StatsVisites? statsVisites;
  final StatsTaches? statsTaches;
  final PeriodType selectedPeriod;
  final bool isLoading;
  final Failure? error;

  const DashboardState({
    this.caMensuel,
    this.caTrimestriel,
    this.statsVisites,
    this.statsTaches,
    this.selectedPeriod = PeriodType.mensuel,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    CAData? caMensuel,
    CAData? caTrimestriel,
    StatsVisites? statsVisites,
    StatsTaches? statsTaches,
    PeriodType? selectedPeriod,
    bool? isLoading,
    Failure? error,
  }) {
    return DashboardState(
      caMensuel: caMensuel ?? this.caMensuel,
      caTrimestriel: caTrimestriel ?? this.caTrimestriel,
      statsVisites: statsVisites ?? this.statsVisites,
      statsTaches: statsTaches ?? this.statsTaches,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  DashboardService get _dashboardService => getIt<DashboardService>();

  @override
  DashboardState build() => const DashboardState();

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    // Load all data in parallel
    final results = await Future.wait([
      _dashboardService.getCaMensuel(),
      _dashboardService.getCaTrimestriel(),
      _dashboardService.getStatsVisites(),
      _dashboardService.getStatsTaches(),
    ]);

    final caMensuel = results[0];
    final caTrimestriel = results[1];
    final statsVisites = results[2];
    final statsTaches = results[3];

    caMensuel.fold(
      (f) => state = state.copyWith(isLoading: false, error: f),
      (data) {
        state = state.copyWith(caMensuel: data as CAData);
      },
    );

    caTrimestriel.fold(
      (_) {},
      (data) => state = state.copyWith(caTrimestriel: data as CAData),
    );

    statsVisites.fold(
      (_) {},
      (data) => state = state.copyWith(statsVisites: data as StatsVisites),
    );

    statsTaches.fold(
      (_) {},
      (data) => state = state.copyWith(
        statsTaches: data as StatsTaches,
        isLoading: false,
      ),
    );
  }

  void selectPeriod(PeriodType period) {
    state = state.copyWith(selectedPeriod: period);
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
