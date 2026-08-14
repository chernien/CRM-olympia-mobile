import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/service_providers.dart';
import '../../core/constants/demande_types.dart';
import '../../core/constants/workflow_roles.dart';
import '../../core/theme/app_colors.dart';
import '../../models/demande_model.dart';
import '../../models/workflow_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/demande_viewmodel.dart';
import '../shared/widgets/status_badge.dart';
import 'widgets/dynamic_form.dart';
import '../shared/widgets/pieces_jointes.dart';

// Workflow schema for a type — lets the timeline show each past step's fields
// with their proper labels. Cached per type, null on error (timeline stays plain).
final _definitionProvider =
    FutureProvider.autoDispose.family<WorkflowDefinition?, int>((ref, type) async {
  final res = await ref.read(demandeServiceProvider).getDefinition(type);
  return res.fold((_) => null, (d) => d);
});

class DemandeDetailView extends ConsumerStatefulWidget {
  final String demandeId;

  const DemandeDetailView({super.key, required this.demandeId});

  @override
  ConsumerState<DemandeDetailView> createState() => _DemandeDetailViewState();
}

class _DemandeDetailViewState extends ConsumerState<DemandeDetailView> {
  // Working state for treating the current phase.
  Map<String, dynamic> _phaseValues = {};

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
  void dispose() {
    super.dispose();
  }

  Future<void> _submitPhase(DemandeModel demande) async {
    final phase = demande.phaseCourante;
    if (phase == null) return;
    final missing = missingRequired(phase.champs, _phaseValues);
    if (missing.isNotEmpty) {
      _snack('Champs requis : ${missing.join(', ')}', ok: false);
      return;
    }
    final fields = fieldsForSubmit(phase.champs, _phaseValues);
    final pieces = collectPieces(phase.champs, _phaseValues);
    final updated = await ref.read(demandeListProvider.notifier).submitPhase(
          demande.id!,
          fields: fields,
          piecesJointes: pieces.isEmpty ? null : pieces,
        );
    if (!mounted) return;
    if (updated != null) {
      _snack('Phase validée', ok: true);
      setState(() { _phaseValues = {}; });
      ref.read(demandeDetailProvider.notifier).loadDemande(widget.demandeId);
    } else {
      _snack(ref.read(demandeListProvider).error?.message ?? 'Échec de la soumission', ok: false);
    }
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white),
        SizedBox(width: 8.w),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: ok ? AppColors.primary : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeDetailProvider);

    // Loading and not-found both keep an app bar, so the back affordance is
    // never missing — the loading state used to be a bare centred spinner on a
    // chrome-less screen, trapping the user until the request resolved.
    if (state.isLoading || state.demande == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            state.isLoading ? 'Chargement…' : 'Demande introuvable',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _buildNotFound(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildContent(state.demande!),
    );
  }

  Widget _buildNotFound() {
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
              child: Icon(Icons.search_off_outlined,
                  size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              'Demande introuvable',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Elle a peut-être été supprimée, ou le lien est incorrect.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DemandeModel demande) {
    final (typeColor, typeIcon) = DemandeTypes.style(demande.typeDemande);
    // Status label comes from StatusBadge so the header and the list cards can
    // never disagree; the local copy here had drifted from it.
    final statusLabel = StatusBadge.labelFor(demande.statut);
    // Workflow schema → lets each timeline step expand its captured fields.
    final def = ref.watch(_definitionProvider(demande.typeDemande)).asData?.value;

    return CustomScrollView(
      slivers: [
        _buildSliverHeader(
          demande,
          typeColor,
          typeIcon,
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
              _buildTreatment(demande),
              _buildPiecesJointes(demande),
              _buildTimeline(demande, def),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

    if (client.isNotEmpty) {
      rows.add((Icons.business_outlined, 'Client', client));
    }
    if (produit.isNotEmpty) {
      rows.add((Icons.layers_outlined, 'Produit', produit));
    }
    if (chantier.isNotEmpty) {
      rows.add((Icons.location_on_outlined, 'Chantier', chantier));
    }
    if (description.isNotEmpty) {
      rows.add((Icons.notes_outlined, 'Description', description));
    }

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
                            color: AppColors.textMuted,
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

  Widget _buildTreatment(DemandeModel demande) {
    final phase = demande.phaseCourante;
    // Closed demande → nothing to treat.
    if (phase == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: _SectionCard(
          title: 'Statut',
          icon: Icons.check_circle_outline,
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18.sp, color: AppColors.secondary),
              SizedBox(width: 8.w),
              Expanded(child: Text('Cette demande est clôturée.',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted))),
            ],
          ),
        ),
      );
    }

    final role = (ref.read(authProvider).user?.role ?? '').toLowerCase();
    final isMine = (demande.roleAttendu ?? '').toLowerCase() == role;

    // Field-only on mobile: a back-office role treats its demandes on the web.
    if (isMine && isOfficeRole(role)) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: _SectionCard(
          title: 'Traitement sur le web',
          icon: Icons.desktop_windows_outlined,
          child: Row(
            children: [
              Icon(Icons.desktop_windows_outlined, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                'Cette demande se traite depuis le back-office web pour votre rôle.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted))),
            ],
          ),
        ),
      );
    }

    final canAct = role == 'admin' || isMine;
    final isSubmitting = ref.watch(demandeListProvider.select((s) => s.isSubmitting));

    if (!canAct) {
      // Not my turn: tell the commercial exactly what the next step is and who owns it.
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: _SectionCard(
          title: 'Prochaine étape',
          icon: Icons.arrow_forward_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      phase.titre,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16.sp, color: AppColors.warning),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'En attente de : ${demande.roleAttenduLabel ?? phase.roleLabel}',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Votre partie est terminée. Cette étape sera traitée par ce rôle avant de vous revenir.',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: _SectionCard(
        title: phase.titre,
        icon: Icons.assignment_turned_in_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DynamicForm(
              champs: phase.champs,
              values: _phaseValues,
              onChanged: (v) => setState(() => _phaseValues = v),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : () => _submitPhase(demande),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                icon: isSubmitting
                    ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Icon(Icons.send_rounded, size: 16.r),
                label: Text('Valider cette phase', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toutes les pièces jointes de la demande : celles portées par la demande
  /// elle-même, plus celles rangées dans les champs « photos » de chaque phase.
  /// Dédoublonnées — un même fichier apparaît souvent aux deux endroits.
  List<String> _toutesLesPieces(DemandeModel d) {
    final vues = <String>{};
    bool estUrl(dynamic x) =>
        x is String && (x.startsWith('/api/fichiers/') || x.startsWith('http'));
    for (final u in (d.piecesJointes ?? const <String>[])) {
      if (u.trim().isNotEmpty) vues.add(u);
    }
    // formData est indexé par phase ; chaque phase porte ses propres champs.
    for (final phase in d.formData.values) {
      if (phase is! Map) continue;
      for (final v in phase.values) {
        if (estUrl(v)) vues.add(v as String);
        if (v is List) {
          for (final e in v) { if (estUrl(e)) vues.add(e as String); }
        }
      }
    }
    return vues.toList();
  }

  Widget _buildPiecesJointes(DemandeModel d) {
    final urls = _toutesLesPieces(d);
    if (urls.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: _SectionCard(
        title: 'Pièces jointes',
        icon: Icons.photo_library_outlined,
        child: PiecesJointes(urls: urls, titre: 'Fichiers'),
      ),
    );
  }

  Widget _buildTimeline(DemandeModel demande, WorkflowDefinition? def) {
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
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
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
          return _TimelineItem(
            item: h,
            isLast: isLast,
            isFirst: index == 0,
            stepData: _stepDataFor(h, demande, def),
          );
        }).toList(),
      ),
    );
  }

  /// Resolves the fields captured during the step this history entry represents,
  /// as (label, value) pairs — or null if the step has no form data (e.g. closure).
  List<(String, String)>? _stepDataFor(
      DemandeHistorique h, DemandeModel d, WorkflowDefinition? def) {
    if (def == null) return null;
    PhaseDef? phase;
    if (h.action == 'Demande créée') {
      phase = def.first;
    } else {
      // "Phase « <titre> » traitée" → find the phase by its title.
      final m = RegExp(r'«\s*(.+?)\s*»').firstMatch(h.action);
      if (m != null) {
        final titre = m.group(1);
        for (final p in def.phases) {
          if (p.titre == titre) { phase = p; break; }
        }
      }
    }
    if (phase == null) return null;
    final raw = d.formData[phase.key];
    if (raw is! Map) return null;

    final out = <(String, String)>[];
    for (final champ in phase.champs) {
      if (!raw.containsKey(champ.name)) continue;
      final val = _formatValue(raw[champ.name]);
      if (val.isEmpty) continue;
      out.add((champ.label, val));
    }
    return out.isEmpty ? null : out;
  }

  /// Human-readable rendering of a stored field value (handles lists, ref-lists, files).
  String _formatValue(dynamic v) {
    if (v == null) return '';
    if (v is List) {
      if (v.isEmpty) return '';
      if (v.first is Map) {
        // ref-list rows → each row's non-empty values joined
        return v
            .map((row) => (row as Map)
                .values
                .where((x) => x != null && '$x'.trim().isNotEmpty)
                .map((x) => '$x')
                .join(' · '))
            .where((s) => s.isNotEmpty)
            .join('\n');
      }
      // checkbox choices / file URLs
      return v.map((x) => '$x'.split('/').last).join(', ');
    }
    return '$v';
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

class _TimelineItem extends StatefulWidget {
  final DemandeHistorique item;
  final bool isLast;
  final bool isFirst;
  // Fields captured at this step (label, value) — null when the step has no data.
  final List<(String, String)>? stepData;

  const _TimelineItem({
    required this.item,
    required this.isLast,
    required this.isFirst,
    this.stepData,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isFirst = widget.isFirst;
    final isLast = widget.isLast;
    final hasData = widget.stepData != null && widget.stepData!.isNotEmpty;
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
              if (!isFirst)
                Container(width: 2.w, height: 8.h, color: AppColors.border),
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst ? AppColors.primary : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Container(width: 2.w, height: 48.h, color: AppColors.border),
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
                // Header row — tappable when there is step data to reveal.
                // Padded to a 44 dp target instead of hugging the text.
                Semantics(
                  button: hasData,
                  expanded: hasData ? _expanded : null,
                  child: InkWell(
                    onTap: hasData
                        ? () => setState(() => _expanded = !_expanded)
                        : null,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      constraints: BoxConstraints(minHeight: hasData ? 44.h : 0),
                      padding: EdgeInsets.symmetric(vertical: hasData ? 8.h : 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.action,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight:
                                    isFirst ? FontWeight.w700 : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            dateLabel,
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColors.textMuted),
                          ),
                          if (hasData)
                            Icon(
                              _expanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 18.r,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (item.auteur != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 12.r, color: AppColors.textSecondary),
                      SizedBox(width: 3.w),
                      Text(
                        item.auteur!,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
                // The chevron on the header row is the single affordance for
                // expanding. There used to be a second "Voir les détails de
                // l'étape" link doing the same job with a ~14 dp target.
                // Expanded panel — the fields captured at this step.
                if (hasData && _expanded) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGhost,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (label, value) in widget.stepData!)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (item.commentaire != null && item.commentaire!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      item.commentaire!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
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
