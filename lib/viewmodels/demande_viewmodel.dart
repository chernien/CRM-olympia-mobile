import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/injection.dart';
import '../core/errors/failures.dart';
import '../models/demande_model.dart';
import '../services/demande_service.dart';

class DemandeListState {
  final List<DemandeModel> demandes;
  final bool isLoading;
  final Failure? error;
  final bool hasMore;
  final int currentPage;
  final int? selectedType;
  final String? selectedStatut;

  const DemandeListState({
    this.demandes = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedType,
    this.selectedStatut,
  });

  DemandeListState copyWith({
    List<DemandeModel>? demandes,
    bool? isLoading,
    Failure? error,
    bool? hasMore,
    int? currentPage,
    int? selectedType,
    String? selectedStatut,
  }) {
    return DemandeListState(
      demandes: demandes ?? this.demandes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedType: selectedType ?? this.selectedType,
      selectedStatut: selectedStatut ?? this.selectedStatut,
    );
  }
}

class DemandeListNotifier extends Notifier<DemandeListState> {
  DemandeService get _demandeService => getIt<DemandeService>();

  @override
  DemandeListState build() => const DemandeListState();

  Future<void> loadDemandes({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(currentPage: 1, demandes: [], hasMore: true);
    }
    if (!state.hasMore && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _demandeService.getDemandes(
      page: state.currentPage,
      typeDemande: state.selectedType,
      statut: state.selectedStatut,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (demandes) => state = state.copyWith(
        isLoading: false,
        demandes: [...state.demandes, ...demandes],
        currentPage: state.currentPage + 1,
        hasMore: demandes.length >= 20,
      ),
    );
  }

  Future<bool> createDemande(DemandeModel demande) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _demandeService.createDemande(demande);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (newDemande) {
        state = state.copyWith(
          isLoading: false,
          demandes: [newDemande, ...state.demandes],
        );
        return true;
      },
    );
  }

  void filterByType(int? type) {
    state = DemandeListState(selectedType: type, selectedStatut: state.selectedStatut);
    loadDemandes(refresh: true);
  }

  void filterByStatut(String? statut) {
    state = DemandeListState(selectedType: state.selectedType, selectedStatut: statut);
    loadDemandes(refresh: true);
  }
}

// Detail state
class DemandeDetailState {
  final DemandeModel? demande;
  final bool isLoading;
  final Failure? error;

  const DemandeDetailState({this.demande, this.isLoading = false, this.error});
}

class DemandeDetailNotifier extends Notifier<DemandeDetailState> {
  DemandeService get _demandeService => getIt<DemandeService>();

  @override
  DemandeDetailState build() => const DemandeDetailState();

  Future<void> loadDemande(String id) async {
    state = const DemandeDetailState(isLoading: true);
    final result = await _demandeService.getDemandeById(id);
    result.fold(
      (f) => state = DemandeDetailState(error: f),
      (d) => state = DemandeDetailState(demande: d),
    );
  }
}

final demandeListProvider = NotifierProvider<DemandeListNotifier, DemandeListState>(DemandeListNotifier.new);

final demandeDetailProvider = NotifierProvider<DemandeDetailNotifier, DemandeDetailState>(DemandeDetailNotifier.new);
