import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/service_providers.dart';
import '../../core/constants/demande_types.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workflow_model.dart';

class DemandeTypeSelectionView extends ConsumerStatefulWidget {
  const DemandeTypeSelectionView({super.key});

  @override
  ConsumerState<DemandeTypeSelectionView> createState() => _DemandeTypeSelectionViewState();
}

class _DemandeTypeSelectionViewState extends ConsumerState<DemandeTypeSelectionView> {
  List<WorkflowDefinition> _defs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final result = await ref.read(demandeServiceProvider).getDefinitions();
    if (!mounted) return;
    result.fold(
      (f) => setState(() { _loading = false; _error = f.message; }),
      (defs) => setState(() { _loading = false; _defs = defs; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nouvelle demande', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('Choisissez le type', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _error != null
                // The error state used to be bare text with no way forward.
                ? _stateMessage(
                    icon: Icons.wifi_off_rounded,
                    title: 'Chargement impossible',
                    body: _error!,
                    onRetry: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _load();
                    },
                  )
                : _defs.isEmpty
                    ? _stateMessage(
                        icon: Icons.article_outlined,
                        title: 'Aucun type disponible',
                        body:
                            'Aucun workflow de demande n\'est configuré. Contactez votre administrateur.',
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                        itemCount: _defs.length,
                        itemBuilder: (context, index) {
                          final d = _defs[index];
                          final steps = d.phases.length;
                          return _TypeTile(
                            label: d.typeLabel,
                            // Was "N phase(s) · workflow" — internal jargon and
                            // a lazy parenthetical plural.
                            subtitle: steps <= 1
                                ? 'Une seule étape'
                                : '$steps étapes de traitement',
                            icon: DemandeTypes.icon(d.type),
                            // Accent follows the type, not the row position, so
                            // it matches the list and detail screens.
                            color: DemandeTypes.color(d.type),
                            onTap: () => context.goNamed(
                              RouteNames.demandeForm,
                              pathParameters: {'type': d.type.toString()},
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  /// Shared shell for the error and empty states.
  Widget _stateMessage({
    required IconData icon,
    required String title,
    required String body,
    VoidCallback? onRetry,
  }) {
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
              child: Icon(icon, size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
                  child: Center(child: Icon(icon, color: color, size: 24.r)),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 3.h),
                      Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14.r, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
