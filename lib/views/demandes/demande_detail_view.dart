import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/demande_viewmodel.dart';
import '../shared/widgets/status_badge.dart';

class DemandeDetailView extends ConsumerStatefulWidget {
  final String demandeId;

  const DemandeDetailView({super.key, required this.demandeId});

  @override
  ConsumerState<DemandeDetailView> createState() => _DemandeDetailViewState();
}

class _DemandeDetailViewState extends ConsumerState<DemandeDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(demandeDetailProvider.notifier)
          .loadDemande(widget.demandeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.demande?.numero ?? 'Détail Demande'),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.demande == null
                ? const Center(child: Text('Demande introuvable'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.demande!.typeLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    StatusBadge(
                                        statut: state.demande!.statut),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'N° ${state.demande!.numero}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Timeline / Historique
                        Text(
                          'Historique',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (state.demande!.historique != null)
                          ...state.demande!.historique!.map(
                            (h) => ListTile(
                              leading: const Icon(Icons.circle, size: 12),
                              title: Text(h.action),
                              subtitle: Text(h.commentaire ?? ''),
                              trailing: Text(
                                '${h.date.day}/${h.date.month}/${h.date.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
