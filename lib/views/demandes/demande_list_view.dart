import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../viewmodels/demande_viewmodel.dart';
import '../shared/widgets/status_badge.dart';

class DemandeListView extends ConsumerStatefulWidget {
  const DemandeListView({super.key});

  @override
  ConsumerState<DemandeListView> createState() => _DemandeListViewState();
}

class _DemandeListViewState extends ConsumerState<DemandeListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(demandeListProvider.notifier).loadDemandes(refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Demandes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.demandeForm),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      ),
      body: SafeArea(
        child: state.isLoading && state.demandes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(demandeListProvider.notifier)
                    .loadDemandes(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.demandes.length,
                  itemBuilder: (context, index) {
                    final demande = state.demandes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => context.goNamed(
                          RouteNames.demandeDetail,
                          pathParameters: {'id': demande.id!},
                        ),
                        title: Text(
                          demande.typeLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(demande.numero ?? 'En attente...'),
                            const SizedBox(height: 4),
                          ],
                        ),
                        trailing: StatusBadge(statut: demande.statut),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
