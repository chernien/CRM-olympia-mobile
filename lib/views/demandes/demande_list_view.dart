import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      appBar: AppBar(
        title: Text('Mes Demandes', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(RouteNames.demandeForm),
            icon: Icon(Icons.add_box_rounded, size: 26.w, color: Theme.of(context).primaryColor),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.demandes.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(demandeListProvider.notifier)
                    .loadDemandes(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.demandes.length,
                  itemBuilder: (context, index) {
                    final demande = state.demandes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        onTap: () => context.goNamed(
                          RouteNames.demandeDetail,
                          pathParameters: {'id': demande.id!},
                        ),
                        title: Text(
                          demande.typeLabel,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6.h),
                            Text(demande.numero ?? 'En attente...', style: TextStyle(fontSize: 14.sp)),
                            SizedBox(height: 4.h),
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
