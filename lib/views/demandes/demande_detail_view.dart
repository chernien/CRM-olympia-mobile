import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../models/demande_model.dart';
import '../../viewmodels/demande_viewmodel.dart';

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

  static (Color, String) _statusInfo(String statut) {
    return switch (statut) {
      'nouvelle' => (AppColors.primary, 'Nouvelle'),
      'en_cours_validation' => (AppColors.secondary, 'En validation'),
      'validee' => (AppColors.primary, 'Validée'),
      'en_cours_traitement' => (AppColors.secondary, 'En traitement'),
      'traitee' => (AppColors.primary, 'Traitée'),
      'cloturee' => (AppColors.secondary, 'Clôturée'),
      'refusee' => (AppColors.secondary, 'Refusée'),
      _ => (AppColors.secondary, statut),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : state.demande == null
          ? _buildNotFound()
          : _buildContent(state.demande!),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande introuvable')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48.r,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Demande introuvable',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DemandeModel demande) {
    final (typeColor, typeIcon) = _typeStyle(demande.typeDemande);
    final (statusColor, statusLabel) = _statusInfo(demande.statut);

    return CustomScrollView(
      slivers: [
        _buildSliverHeader(
          demande,
          typeColor,
          typeIcon,
          statusColor,
          statusLabel,
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_hasKeyDetails(demande)) ...[
                _buildKeyDetails(demande),
                SizedBox(height: 20.h),
              ],
              _buildTimeline(demande),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(
    DemandeModel demande,
    Color typeColor,
    IconData typeIcon,
    Color statusColor,
    String statusLabel,
  ) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: typeColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [typeColor, typeColor.withValues(alpha: 0.75)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(typeIcon, color: Colors.white, size: 22.r),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    demande.typeLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (demande.numero != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            demande.numero!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (demande.createdAt != null) ...[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12.r,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(demande.createdAt!),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasKeyDetails(DemandeModel demande) {
    final data = demande.formData;
    return (data['client'] as String? ?? '').isNotEmpty ||
        (data['chantier'] as String? ?? '').isNotEmpty ||
        (data['produit'] as String? ?? '').isNotEmpty;
  }

  Widget _buildKeyDetails(DemandeModel demande) {
    final data = demande.formData;
    final rows = <(IconData, String, String)>[];
    final client = data['client'] as String? ?? '';
    final chantier = data['chantier'] as String? ?? '';
    final produit = data['produit'] as String? ?? '';
    final description = data['description'] as String? ?? '';

    if (client.isNotEmpty)
      rows.add((Icons.business_outlined, 'Client', client));
    if (produit.isNotEmpty)
      rows.add((Icons.layers_outlined, 'Produit', produit));
    if (chantier.isNotEmpty)
      rows.add((Icons.location_on_outlined, 'Chantier', chantier));
    if (description.isNotEmpty)
      rows.add((Icons.notes_outlined, 'Description', description));

    if (rows.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Informations',
      icon: Icons.info_outline,
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final (icon, label, value) = entry.value;
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16.r, color: AppColors.textSecondary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                SizedBox(height: 12.h),
                Divider(color: AppColors.border, height: 1),
                SizedBox(height: 12.h),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline(DemandeModel demande) {
    final historique = demande.historique ?? [];
    if (historique.isEmpty) {
      return _SectionCard(
        title: 'Historique',
        icon: Icons.timeline_outlined,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Aucun historique disponible',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'Historique',
      icon: Icons.timeline_outlined,
      child: Column(
        children: historique.asMap().entries.map((entry) {
          final index = entry.key;
          final h = entry.value;
          final isLast = index == historique.length - 1;
          return _TimelineItem(item: h, isLast: isLast, isFirst: index == 0);
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Icon(icon, size: 16.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          Padding(padding: EdgeInsets.all(16.r), child: child),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DemandeHistorique item;
  final bool isLast;
  final bool isFirst;

  const _TimelineItem({
    required this.item,
    required this.isLast,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line + dot
        SizedBox(
          width: 24.w,
          child: Column(
            children: [
              // Top line
              if (!isFirst)
                Container(width: 2.w, height: 8.h, color: AppColors.border),
              // Dot
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
              ),
              // Bottom line
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Container(
                    width: 2.w,
                    height: 48.h,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.action,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isFirst
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (item.auteur != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.auteur!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.commentaire != null &&
                    item.commentaire!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      item.commentaire!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
