import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/service_providers.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../models/demande_model.dart';
import '../services/demande_service.dart';

// Sentinel: lets copyWith distinguish "not provided" from explicit null.
const _absent = Object();

class DemandeListState {
  final List<DemandeModel> demandes;

  /// True while the paginated list is being fetched.
  final bool isLoading;

  /// True while a create/updateStatus mutation is in-flight.
  final bool isSubmitting;

  final Failure? error;
  final bool hasMore;
  final int currentPage;
  final int? selectedType;
  final String? selectedStatut;

  const DemandeListState({
    this.demandes = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedType,
    this.selectedStatut,
  });

  DemandeListState copyWith({
    List<DemandeModel>? demandes,
    bool? isLoading,
    bool? isSubmitting,
    Failure? error,
    bool? hasMore,
    int? currentPage,
    // Sentinel-based nullable fields so null can be passed to clear filters.
    Object? selectedType = _absent,
    Object? selectedStatut = _absent,
  }) {
    return DemandeListState(
      demandes: demandes ?? this.demandes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedType: identical(selectedType, _absent)
          ? this.selectedType
          : selectedType as int?,
      selectedStatut: identical(selectedStatut, _absent)
          ? this.selectedStatut
          : selectedStatut as String?,
    );
  }
}

class DemandeListNotifier extends Notifier<DemandeListState> {
  late final DemandeService _demandeService;

  @override
  DemandeListState build() {
    _demandeService = ref.read(demandeServiceProvider);
    return const DemandeListState();
  }

  Future<void> loadDemandes({bool refresh = false}) async {
    if (!state.hasMore && !refresh) return;
    // Guard: prevents scroll over-fire while a fetch is already in progress.
    if (state.isLoading) return;

    if (refresh) {
      state = DemandeListState(
        isLoading: true,
        selectedType: state.selectedType,
        selectedStatut: state.selectedStatut,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _demandeService.getDemandes(
      page: state.currentPage,
      typeDemande: state.selectedType,
      statut: state.selectedStatut,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (demandes) {
        state = state.copyWith(
          isLoading: false,
          demandes: [...state.demandes, ...demandes],
          currentPage: state.currentPage + 1,
          hasMore: demandes.length == AppConstants.defaultPageSize &&
              demandes.isNotEmpty,
        );
      },
    );
  }

  Future<bool> createDemande(DemandeModel demande) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _demandeService.createDemande(demande);

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure);
        return false;
      },
      (newDemande) {
        state = state.copyWith(
          isSubmitting: false,
          demandes: [newDemande, ...state.demandes],
        );
        return true;
      },
    );
  }

  Future<bool> updateDemandeStatus(
    String demandeId,
    String statut, {
    String? commentaire,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _demandeService.updateDemandeStatus(
      demandeId,
      statut,
      commentaire: commentaire,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure);
        return false;
      },
      (updated) {
        final updatedList = state.demandes
            .map((d) => d.id == demandeId ? updated : d)
            .toList();
        state = state.copyWith(isSubmitting: false, demandes: updatedList);
        return true;
      },
    );
  }

  void filterByType(int? type) {
    state = DemandeListState(
      selectedType: type,
      selectedStatut: state.selectedStatut,
    );
    loadDemandes(refresh: true);
  }

  void filterByStatut(String? statut) {
    state = DemandeListState(
      selectedType: state.selectedType,
      selectedStatut: statut,
    );
    loadDemandes(refresh: true);
  }
}

// ─── Detail state ─────────────────────────────────────────────────────────────

class DemandeDetailState {
  final DemandeModel? demande;
  final bool isLoading;
  final Failure? error;

  const DemandeDetailState(
      {this.demande, this.isLoading = false, this.error});
}

class DemandeDetailNotifier extends Notifier<DemandeDetailState> {
  late final DemandeService _demandeService;

  @override
  DemandeDetailState build() {
    _demandeService = ref.read(demandeServiceProvider);
    return const DemandeDetailState();
  }

  Future<void> loadDemande(String id) async {
    state = const DemandeDetailState(isLoading: true);
    final result = await _demandeService.getDemandeById(id);
    result.fold(
      (f) => state = DemandeDetailState(error: f),
      (d) => state = DemandeDetailState(demande: d),
    );
  }
}

final demandeListProvider =
    NotifierProvider<DemandeListNotifier, DemandeListState>(
        DemandeListNotifier.new);

final demandeDetailProvider =
    NotifierProvider.autoDispose<DemandeDetailNotifier, DemandeDetailState>(
        DemandeDetailNotifier.new);
