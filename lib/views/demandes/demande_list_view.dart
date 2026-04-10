import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
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

class _DemandeListViewState extends ConsumerState<DemandeListView>
    with AutomaticKeepAliveClientMixin {
  final _scroll = ScrollController();

  static const _statutFilters = [
    ('tous', 'Toutes'),
    ('nouvelle', 'Nouvelles'),
    ('en_cours_validation', 'En validation'),
    ('validee', 'Validées'),
    ('en_cours_traitement', 'En traitement'),
    ('refusee', 'Refusées'),
  ];

  static const _typeLabels = <int, String>{
    1: 'Échantillons',
    2: 'Échantillons + app.',
    3: 'Réclamation',
    4: 'Nouveau client',
    5: 'Renouvellement showroom',
    6: 'Formation',
    7: 'Assistance chantier',
    8: 'Machine à teinter',
    9: 'Accessoires marketing',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(demandeListProvider.notifier).loadDemandes(refresh: true),
    );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Guard: skip if already loading or nothing more to fetch.
    final s = ref.read(demandeListProvider);
    if (s.isLoading || !s.hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(demandeListProvider.notifier).loadDemandes();
    }
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

  void _showTypeFilter() {
    HapticFeedback.lightImpact();
    final currentType = ref.read(demandeListProvider).selectedType;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtrer par type',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    if (currentType != null)
                      InkWell(
                        onTap: () {
                          ref
                              .read(demandeListProvider.notifier)
                              .filterByType(null);
                          Navigator.of(sheetContext).pop();
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Réinitialiser',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                _typeFilterTile(
                    null, 'Tous les types', currentType, sheetContext),
                ..._typeLabels.entries.map((e) =>
                    _typeFilterTile(e.key, e.value, currentType, sheetContext)),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typeFilterTile(int? value, String label, int? currentType,
      BuildContext sheetContext) {
    final isSelected = value == currentType;
    const unselectedBorder = Color(0xFFCBD5E1);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : unselectedBorder,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, color: Colors.white, size: 13.r)
            : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () {
        ref.read(demandeListProvider.notifier).filterByType(value);
        Navigator.of(sheetContext).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(demandeListProvider);
    final activeFilter = state.selectedStatut ?? 'tous';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(activeFilter),
            // Error banner
            if (state.error != null)
              _ErrorBanner(
                message: state.error!.message,
                onRetry: () => ref
                    .read(demandeListProvider.notifier)
                    .loadDemandes(refresh: true),
              ),
            Expanded(
              child: state.isInitialLoad
                  ? const _DemandeListSkeleton()
                  : state.demandes.isEmpty
                      ? _buildEmptyState(activeFilter)
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(demandeListProvider.notifier)
                              .loadDemandes(refresh: true),
                          child: ListView.builder(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                16.w, 8.h, 16.w, 100.h),
                            itemCount: state.demandes.length +
                                (state.isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.demandes.length) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 16.h),
                                  child: const Center(
                                    child:
                                        CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              }
                              return _DemandeCard(
                                key: ValueKey(state.demandes[index].id),
                                demande: state.demandes[index],
                                typeStyle: _typeStyle,
                                onTap: () => context.goNamed(
                                  RouteNames.demandeDetail,
                                  pathParameters: {
                                    'id': state.demandes[index].id!
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DemandeListState state) {
    final count = state.demandes.length;
    final hasFilter =
        state.selectedStatut != null || state.selectedType != null;
    final subtitle = hasFilter
        ? '$count demande${count != 1 ? 's' : ''} filtrée${count != 1 ? 's' : ''}'
        : '$count demande${count > 1 ? 's' : ''} au total';

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes Demandes',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showTypeFilter,
          tooltip: 'Filtrer par type',
          icon: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: state.selectedType != null
                  ? AppColors.primary
                  : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: state.selectedType != null
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: state.selectedType != null
                  ? Colors.white
                  : AppColors.textSecondary,
              size: 18.r,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.goNamed(RouteNames.demandeTypeSelection),
          tooltip: 'Nouvelle demande',
          icon: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 20.r),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildFilterChips(String activeFilter) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _statutFilters.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final (value, label) = _statutFilters[index];
            final isActive = activeFilter == value;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref
                    .read(demandeListProvider.notifier)
                    .filterByStatut(value == 'tous' ? null : value);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color:
                        isActive ? AppColors.primary : AppColors.border,
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

  Widget _buildEmptyState(String activeFilter) {
    final isFiltered = activeFilter != 'tous';
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
                color: AppColors.primaryGhost,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined,
                  size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              isFiltered
                  ? 'Aucune demande dans cette catégorie'
                  : 'Aucune demande',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              isFiltered
                  ? 'Essayez de changer le filtre ou créez une nouvelle demande.'
                  : 'Créez votre première demande en appuyant sur le bouton ci-dessous.',
              style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.goNamed(RouteNames.demandeTypeSelection),
                icon: const Icon(Icons.add),
                label: const Text('Créer une demande'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Extracted card widget ─────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  final DemandeModel demande;
  final (Color, IconData) Function(int type) typeStyle;
  final VoidCallback onTap;

  const _DemandeCard({
    super.key,
    required this.demande,
    required this.typeStyle,
    required this.onTap,
  });

  String get _dateLabel {
    final date = demande.createdAt;
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final (typeColor, typeIcon) = typeStyle(demande.typeDemande);
    final client = demande.formData['client'] as String? ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
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
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            if (demande.numero != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  demande.numero!,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            if (demande.numero != null &&
                                _dateLabel.isNotEmpty)
                              SizedBox(width: 6.w),
                            if (_dateLabel.isNotEmpty) ...[
                              Icon(Icons.calendar_today_outlined,
                                  size: 10.r,
                                  color: AppColors.textSecondary),
                              SizedBox(width: 3.w),
                              Text(_dateLabel,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.textSecondary)),
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
                      Icon(Icons.chevron_right,
                          size: 16.r, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer skeleton ──────────────────────────────────────────────────────────

class _DemandeListSkeleton extends StatelessWidget {
  const _DemandeListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, _) => Container(
          margin: EdgeInsets.only(bottom: 10.h),
          height: 88.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

// ─── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _DemandeInitialLoad on DemandeListState {
  bool get isInitialLoad => isLoading && demandes.isEmpty;
}
