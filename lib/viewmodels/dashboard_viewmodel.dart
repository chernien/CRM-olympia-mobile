import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/service_providers.dart';
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

  /// True only on the very first load (no data in hand yet).
  bool get isInitialLoad => isLoading && caMensuel == null;

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
  late final DashboardService _dashboardService;

  @override
  DashboardState build() {
    _dashboardService = ref.read(dashboardServiceProvider);
    return const DashboardState();
  }

  Future<void> loadDashboard({bool refresh = false}) async {
    if (refresh) _dashboardService.clearCache();
    state = state.copyWith(isLoading: true, error: null);

    // Load all data in parallel.
    final results = await Future.wait([
      _dashboardService.getCaMensuel(),
      _dashboardService.getCaTrimestriel(),
      _dashboardService.getStatsVisites(),
      _dashboardService.getStatsTaches(),
    ]);

    // Collect results before updating state to avoid sequential copyWith
    // overwriting each other's error field.
    CAData? caMensuel;
    CAData? caTrimestriel;
    StatsVisites? statsVisites;
    StatsTaches? statsTaches;
    Failure? error;

    results[0].fold((f) => error ??= f, (d) => caMensuel = d as CAData);
    results[1].fold((f) => error ??= f, (d) => caTrimestriel = d as CAData);
    results[2]
        .fold((f) => error ??= f, (d) => statsVisites = d as StatsVisites);
    results[3].fold((f) => error ??= f, (d) => statsTaches = d as StatsTaches);

    state = DashboardState(
      caMensuel: caMensuel ?? state.caMensuel,
      caTrimestriel: caTrimestriel ?? state.caTrimestriel,
      statsVisites: statsVisites ?? state.statsVisites,
      statsTaches: statsTaches ?? state.statsTaches,
      selectedPeriod: state.selectedPeriod,
      isLoading: false,
      error: error,
    );
  }

  void selectPeriod(PeriodType period) {
    state = state.copyWith(selectedPeriod: period);
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
