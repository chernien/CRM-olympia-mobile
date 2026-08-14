import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/service_providers.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workflow_model.dart';
import '../../viewmodels/demande_viewmodel.dart';
import 'widgets/dynamic_form.dart';

/// Creation form for a demande type: renders phase 1 dynamically from the
/// workflow schema and submits it (createFromPhase1).
class DemandeFormView extends ConsumerStatefulWidget {
  final int type;
  const DemandeFormView({super.key, required this.type});

  @override
  ConsumerState<DemandeFormView> createState() => _DemandeFormViewState();
}

class _DemandeFormViewState extends ConsumerState<DemandeFormView> {
  Map<String, dynamic> _values = {};
  WorkflowDefinition? _def;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDefinition);
  }

  Future<void> _loadDefinition() async {
    final result = await ref.read(demandeServiceProvider).getDefinition(widget.type);
    if (!mounted) return;
    result.fold(
      (f) => setState(() { _loading = false; _loadError = f.message; }),
      (def) => setState(() { _loading = false; _def = def; }),
    );
  }

  PhaseDef? get _phase1 => _def?.first;

  Future<void> _submit() async {
    final phase = _phase1;
    if (phase == null) return;
    final missing = missingRequired(phase.champs, _values);
    if (missing.isNotEmpty) {
      _snack('Champs requis : ${missing.join(', ')}', ok: false);
      return;
    }
    final fields = fieldsForSubmit(phase.champs, _values);
    final pieces = collectPieces(phase.champs, _values);
    // The client name is derived server-side from the workflow's own client field.
    final created = await ref.read(demandeListProvider.notifier).createFromPhase1(
          typeDemande: widget.type,
          fields: fields,
          piecesJointes: pieces.isEmpty ? null : pieces,
        );
    if (!mounted) return;
    if (created != null) {
      _snack('Demande créée avec succès', ok: true);
      context.go(RouteNames.demandes);
    } else {
      _snack(ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue', ok: false);
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
    final isSubmitting = ref.watch(demandeListProvider.select((s) => s.isSubmitting));
    final phase = _phase1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          _def?.typeLabel ?? 'Nouvelle demande',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _loadError != null
                ? _errorState(_loadError!)
                : phase == null
                    ? _errorState('Ce type de demande n\'a pas de workflow.')
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // No static client input: each workflow declares its own
                                  // client field (or none, e.g. support marketing).
                                  _sectionTitle(phase.titre, Icons.assignment_outlined),
                                  SizedBox(height: 12.h),
                                  DynamicForm(
                                    champs: phase.champs,
                                    values: _values,
                                    onChanged: (v) => setState(() => _values = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _submitBar(isSubmitting),
                        ],
                      ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );

  Widget _errorState(String msg) => Center(
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
                child: Icon(Icons.error_outline,
                    size: 36.r, color: AppColors.primary),
              ),
              SizedBox(height: 20.h),
              Text('Formulaire indisponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              SizedBox(height: 8.h),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                      height: 1.5)),
              SizedBox(height: 24.h),
              // The dead end used to have no way out but the system back gesture.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _loadDefinition();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _submitBar(bool isSubmitting) => Container(
        // Extra bottom room clears the Android gesture bar under the sticky
        // action, matching FormBottomNav elsewhere.
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: isSubmitting
                ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Soumettre la demande', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8.w),
                      Icon(Icons.send_rounded, size: 16.r),
                    ],
                  ),
          ),
        ),
      );
}
