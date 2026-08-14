import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/service_providers.dart';
import '../core/errors/failures.dart';
import '../models/ca_categorie.dart';
import '../models/dashboard_model.dart';
import '../models/objectif_progress.dart';
import '../services/dashboard_service.dart';

enum PeriodType { mensuel, trimestriel, global }

class DashboardState {
  final CAData? caMensuel;
  final CAData? caTrimestriel;

  /// CA « Global » : tout depuis le début, toutes périodes confondues.
  final CAData? caGlobal;
  final StatsVisites? statsVisites;
  final StatsTaches? statsTaches;
  final PeriodType selectedPeriod;
  final bool isLoading;
  final Failure? error;
  final List<ObjectifProgress> objectifs;

  /// CA split by article category for the selected period (null = still loading).
  final CaCategories? caCategories;

  const DashboardState({
    this.caMensuel,
    this.caTrimestriel,
    this.caGlobal,
    this.statsVisites,
    this.statsTaches,
    this.selectedPeriod = PeriodType.mensuel,
    this.isLoading = false,
    this.error,
    this.objectifs = const [],
    this.caCategories,
  });

  /// True only on the very first load (no data in hand yet).
  bool get isInitialLoad => isLoading && caMensuel == null;

  DashboardState copyWith({
    CAData? caMensuel,
    CAData? caTrimestriel,
    CAData? caGlobal,
    StatsVisites? statsVisites,
    StatsTaches? statsTaches,
    PeriodType? selectedPeriod,
    bool? isLoading,
    Failure? error,
    List<ObjectifProgress>? objectifs,
    CaCategories? caCategories,
  }) {
    return DashboardState(
      caMensuel: caMensuel ?? this.caMensuel,
      caTrimestriel: caTrimestriel ?? this.caTrimestriel,
      caGlobal: caGlobal ?? this.caGlobal,
      statsVisites: statsVisites ?? this.statsVisites,
      statsTaches: statsTaches ?? this.statsTaches,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      objectifs: objectifs ?? this.objectifs,
      caCategories: caCategories ?? this.caCategories,
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
      _dashboardService.getCaGlobal(),
      _dashboardService.getStatsVisites(),
      _dashboardService.getStatsTaches(),
    ]);

    // Collect results before updating state to avoid sequential copyWith
    // overwriting each other's error field.
    CAData? caMensuel;
    CAData? caTrimestriel;
    CAData? caGlobal;
    StatsVisites? statsVisites;
    StatsTaches? statsTaches;
    Failure? error;

    results[0].fold((f) => error ??= f, (d) => caMensuel = d as CAData);
    results[1].fold((f) => error ??= f, (d) => caTrimestriel = d as CAData);
    results[2].fold((f) => error ??= f, (d) => caGlobal = d as CAData);
    results[3]
        .fold((f) => error ??= f, (d) => statsVisites = d as StatsVisites);
    results[4].fold((f) => error ??= f, (d) => statsTaches = d as StatsTaches);

    state = DashboardState(
      caMensuel: caMensuel ?? state.caMensuel,
      caTrimestriel: caTrimestriel ?? state.caTrimestriel,
      caGlobal: caGlobal ?? state.caGlobal,
      statsVisites: statsVisites ?? state.statsVisites,
      statsTaches: statsTaches ?? state.statsTaches,
      selectedPeriod: state.selectedPeriod,
      isLoading: false,
      error: error,
      objectifs: state.objectifs,
    );

    // Load the commercial's objective attainment (independent — never blocks the dashboard).
    final objRes = await _dashboardService.getObjectifsProgress();
    objRes.fold((_) {}, (list) => state = state.copyWith(objectifs: list));

    await _loadCategories();
  }

  /// CA split by article category for the currently selected period.
  Future<void> _loadCategories() async {
    final periode = switch (state.selectedPeriod) {
      PeriodType.mensuel => 'month',
      PeriodType.trimestriel => 'quarter',
      PeriodType.global => 'all',
    };
    final res = await _dashboardService.getCaCategories(periode);
    res.fold((_) {}, (c) => state = state.copyWith(caCategories: c));
  }

  void selectPeriod(PeriodType period) {
    // Reset the category split (it is period-scoped) then reload it.
    state = DashboardState(
      caMensuel: state.caMensuel,
      caTrimestriel: state.caTrimestriel,
      caGlobal: state.caGlobal,
      statsVisites: state.statsVisites,
      statsTaches: state.statsTaches,
      selectedPeriod: period,
      isLoading: state.isLoading,
      error: state.error,
      objectifs: state.objectifs,
      caCategories: null,
    );
    _loadCategories();
  }

  /// Marks an objective's congratulations as shown (server-side, idempotent)
  /// and reflects it locally so the popup can't re-fire within this session.
  void markCelebrated(String objectifId) {
    _dashboardService.markObjectifCelebrated(objectifId);
    state = state.copyWith(
      objectifs: [
        for (final o in state.objectifs)
          if (o.id == objectifId)
            ObjectifProgress(
              id: o.id,
              type: o.type,
              titre: o.titre,
              valeur: o.valeur,
              description: o.description,
              periode: o.periode,
              caRealise: o.caRealise,
              pct: o.pct,
              celebrated: true,
            )
          else
            o,
      ],
    );
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
