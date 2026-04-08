import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/demande_model.dart';
import '../../viewmodels/demande_viewmodel.dart';
import '../shared/widgets/status_badge.dart';

class DemandeListView extends ConsumerStatefulWidget {
  const DemandeListView({super.key});

  @override
  ConsumerState<DemandeListView> createState() => _DemandeListViewState();
}

class _DemandeListViewState extends ConsumerState<DemandeListView> {
  String _activeFilter = 'tous';

  static const _filters = [
    ('tous', 'Toutes'),
    ('nouvelle', 'Nouvelles'),
    ('en_cours_validation', 'En validation'),
    ('validee', 'Validées'),
    ('en_cours_traitement', 'En traitement'),
    ('refusee', 'Refusées'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(demandeListProvider.notifier).loadDemandes(refresh: true),
    );
  }

  List<DemandeModel> _filtered(List<DemandeModel> all) {
    if (_activeFilter == 'tous') return all;
    return all.where((d) => d.statut == _activeFilter).toList();
  }

  static (Color, IconData) _typeStyle(int type) {
    return switch (type) {
      1 => (AppColors.primary, Icons.colorize_outlined),
      2 => (AppColors.secondary, Icons.brush_outlined),
      3 => (AppColors.primary, Icons.report_problem_outlined),
      4 => (AppColors.secondary, Icons.person_add_outlined),
      5 => (AppColors.primary, Icons.store_outlined),
      6 => (AppColors.secondary, Icons.school_outlined),
      7 => (AppColors.primary, Icons.construction_outlined),
      8 => (AppColors.secondary, Icons.precision_manufacturing_outlined),
      9 => (AppColors.primary, Icons.campaign_outlined),
      _ => (AppColors.secondary, Icons.article_outlined),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeListProvider);
    final filtered = _filtered(state.demandes);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state.demandes.length),
      body: SafeArea(
        child: state.isLoading && state.demandes.isEmpty
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Column(
                children: [
                  _buildFilterChips(),
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(demandeListProvider.notifier)
                                .loadDemandes(refresh: true),
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  _buildDemandeCard(filtered[index]),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int total) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes Demandes', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('$total demande${total > 1 ? 's' : ''} au total', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.goNamed(RouteNames.demandeTypeSelection),
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 20.r),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final (value, label) = _filters[index];
            final isActive = _activeFilter == value;
            return GestureDetector(
              onTap: () => setState(() => _activeFilter = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDemandeCard(DemandeModel demande) {
    final (typeColor, typeIcon) = _typeStyle(demande.typeDemande);
    final date = demande.createdAt;
    final dateLabel = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : '';
    final client = demande.formData['client'] as String? ?? '';

    return GestureDetector(
      onTap: () => context.goNamed(
        RouteNames.demandeDetail,
        pathParameters: {'id': demande.id!},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left color bar
            Container(
              width: 4.w,
              height: 88.h,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
              ),
            ),
            // Icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(typeIcon, color: typeColor, size: 22.r),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demande.typeLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    if (client.isNotEmpty)
                      Text(
                        client,
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        if (demande.numero != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              demande.numero!,
                              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        if (demande.numero != null && dateLabel.isNotEmpty) SizedBox(width: 6.w),
                        if (dateLabel.isNotEmpty) ...[
                          Icon(Icons.calendar_today_outlined, size: 10.r, color: AppColors.textSecondary),
                          SizedBox(width: 3.w),
                          Text(dateLabel, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Status badge
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(statut: demande.statut),
                  SizedBox(height: 8.h),
                  Icon(Icons.chevron_right, size: 16.r, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined, size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              _activeFilter == 'tous' ? 'Aucune demande' : 'Aucune demande dans cette catégorie',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _activeFilter == 'tous'
                  ? 'Créez votre première demande en appuyant sur le bouton ci-dessous.'
                  : 'Essayez de changer le filtre ou créez une nouvelle demande.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
