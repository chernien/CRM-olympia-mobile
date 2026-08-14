import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/demande_types.dart';
import '../../core/constants/workflow_roles.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/demande_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/demande_viewmodel.dart';
import '../shared/widgets/error_banner.dart';
import '../shared/widgets/status_badge.dart';

class DemandeListView extends ConsumerStatefulWidget {
  const DemandeListView({super.key});

  @override
  ConsumerState<DemandeListView> createState() => _DemandeListViewState();
}

class _DemandeListViewState extends ConsumerState<DemandeListView>
    with AutomaticKeepAliveClientMixin {
  final _scroll = ScrollController();
  String _mode = 'mine'; // 'mine' = my demandes list · 'inbox' = à traiter

  static const _statutFilters = [
    ('tous', 'Toutes'),
    ('nouvelle', 'Nouvelles'),
    ('en_cours_validation', 'En validation'),
    ('validee', 'Validées'),
    ('en_cours_traitement', 'En traitement'),
    ('en_production', 'En production'),
    ('cloturee', 'Clôturées'),
    ('refusee', 'Refusées'),
  ];

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
                ...DemandeTypes.labels.entries.map((e) =>
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: isSelected,
      leading: Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderStrong,
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
            _buildModeToggle(),
            if (_mode == 'mine') _buildFilterChips(activeFilter),
            // Error banner
            if (_mode == 'mine' && state.error != null)
              ErrorBanner(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                message: state.error!.message,
                onRetry: () => ref
                    .read(demandeListProvider.notifier)
                    .loadDemandes(refresh: true),
              ),
            Expanded(
              child: _mode == 'inbox' ? _buildInboxBody() : _buildMineBody(state, activeFilter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineBody(DemandeListState state, String activeFilter) {
    return state.isInitialLoad
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
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                  itemCount: state.demandes.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.demandes.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(child: CircularProgressIndicator.adaptive()),
                      );
                    }
                    return _DemandeCard(
                      key: ValueKey(state.demandes[index].id),
                      demande: state.demandes[index],
                      typeStyle: DemandeTypes.style,
                      onTap: () => context.goNamed(
                        RouteNames.demandeDetail,
                        pathParameters: {'id': state.demandes[index].id!},
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildInboxBody() {
    // Field-only on mobile: back-office roles are redirected to the web.
    final role = ref.watch(authProvider).user?.role;
    if (isOfficeRole(role)) return _buildWebOnlyNotice();

    final asyncInbox = ref.watch(demandeInboxProvider);
    return asyncInbox.when(
      loading: () => const _DemandeListSkeleton(),
      error: (e, _) => _buildEmptyState('inbox_error'),
      data: (list) {
        if (list.isEmpty) return _buildEmptyState('inbox_empty');
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(demandeInboxProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
            itemCount: list.length,
            itemBuilder: (context, index) => _DemandeCard(
              key: ValueKey(list[index].id),
              demande: list[index],
              typeStyle: DemandeTypes.style,
              onTap: () => context.goNamed(
                RouteNames.demandeDetail,
                pathParameters: {'id': list[index].id!},
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebOnlyNotice() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(color: AppColors.primaryGhost, shape: BoxShape.circle),
              child: Icon(Icons.desktop_windows_outlined, size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              'Traitement sur le back-office',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Pour votre rôle, les demandes à traiter se gèrent depuis le back-office web. '
              'L\'application mobile est réservée au suivi de terrain.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    Widget seg(String key, String label, IconData icon) {
      final active = _mode == key;
      return Expanded(
        child: Semantics(
          button: true,
          selected: active,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_mode == key) return;
              HapticFeedback.selectionClick();
              setState(() => _mode = key);
              if (key == 'inbox') ref.invalidate(demandeInboxProvider);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // 44 dp minimum — the segment was ~36 dp tall.
              constraints: BoxConstraints(minHeight: 44.h),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 16.r,
                      color: active ? Colors.white : AppColors.textMuted),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color:
                                active ? Colors.white : AppColors.textMuted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14.r)),
        child: Row(children: [
          seg('mine', 'Mes demandes', Icons.folder_outlined),
          seg('inbox', 'À traiter', Icons.inbox_outlined),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DemandeListState state) {
    // Title and count follow the active tab — the bar used to read
    // "Mes Demandes / N au total" even while the inbox was on screen.
    final isInbox = _mode == 'inbox';
    final count = state.demandes.length;
    final hasFilter =
        state.selectedStatut != null || state.selectedType != null;
    final subtitle = isInbox
        ? 'Demandes en attente de votre rôle'
        : hasFilter
            ? '$count demande${count != 1 ? 's' : ''} filtrée${count != 1 ? 's' : ''}'
            : '$count demande${count != 1 ? 's' : ''} au total';

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInbox ? 'À traiter' : 'Mes demandes',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        // The type filter only drives "Mes demandes"; hiding it in the inbox
        // avoids a control that looks live but changes nothing on screen.
        if (!isInbox)
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
                      : AppColors.borderStrong,
                ),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: state.selectedType != null
                    ? Colors.white
                    : AppColors.textMuted,
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
      // 44 dp row: the chips were ~28 dp tall, well under the touch minimum.
      child: SizedBox(
        height: 44.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _statutFilters.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final (value, label) = _statutFilters[index];
            final isActive = activeFilter == value;
            return Semantics(
              button: true,
              selected: isActive,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(demandeListProvider.notifier)
                      .filterByStatut(value == 'tous' ? null : value);
                },
                borderRadius: BorderRadius.circular(22.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color:
                          isActive ? AppColors.primary : AppColors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
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
    final isInbox = activeFilter.startsWith('inbox');
    final isFiltered = activeFilter != 'tous' && !isInbox;
    if (isInbox) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(color: AppColors.primaryGhost, shape: BoxShape.circle),
                child: Icon(activeFilter == 'inbox_error' ? Icons.error_outline : Icons.inbox_outlined,
                    size: 36.r, color: AppColors.primary),
              ),
              SizedBox(height: 20.h),
              Text(
                activeFilter == 'inbox_error' ? 'Erreur de chargement' : 'Rien à traiter',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                activeFilter == 'inbox_error'
                    ? 'Impossible de récupérer les demandes à traiter.'
                    : 'Aucune demande n\'attend une action de votre rôle.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
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
                  : 'Créez votre première demande avec le bouton ci-dessous.',
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
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
                // The type accent lives on the icon tile. There used to also be
                // a 4 px colored bar pinned to 88 dp, which stopped short as
                // soon as the card grew past that height (long client name).
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 0),
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
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
                                fontSize: 12.sp, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 6.h),
                        // Wrap, not Row: a long demande number used to push the
                        // date past the card edge and overflow.
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            if (_dateLabel.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 10.r, color: AppColors.textMuted),
                                  SizedBox(width: 3.w),
                                  Text(_dateLabel,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: AppColors.textMuted)),
                                ],
                              ),
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

extension _DemandeInitialLoad on DemandeListState {
  bool get isInitialLoad => isLoading && demandes.isEmpty;
}
