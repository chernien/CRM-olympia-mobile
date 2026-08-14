import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  /// Every role gets its own French label. This used to collapse to
  /// "Administrateur" or "Commercial", so a Technicien was shown as Commercial.
  static String _roleLabel(String? role) {
    return switch ((role ?? '').toLowerCase()) {
      'admin' => 'Administrateur',
      'commercial' => 'Commercial',
      'technicien' => 'Technicien',
      'directioncommerciale' => 'Direction commerciale',
      'responsabletechnique' => 'Responsable technique',
      'servicerecouvrement' => 'Service recouvrement',
      '' => 'Utilisateur',
      _ => role!,
    };
  }

  /// Amounts are shown raw, never rounded — `toStringAsFixed(0)` was silently
  /// rounding the objective (e.g. 499 999,6 → "500000").
  static String _amount(double value) {
    final s = value.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final name = user?.fullName ?? 'Utilisateur';
    final roleLabel = _roleLabel(user?.role);
    final email = user?.email ?? 'Non renseigné';
    final objectifCA = user?.objectifCA;
    final initials = user != null && user.prenom.isNotEmpty && user.nom.isNotEmpty
        ? '${user.prenom[0]}${user.nom[0]}'.toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mon profil')),
      body: SafeArea(
        child: ListView(
          // 100.h clears the floating bottom nav bar (extendBody is on in
          // MainShell). At 24.h the logout button sat underneath it.
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.95),
                    AppColors.secondary.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(name, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 6.h),
                  Text(email, style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.9))),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildDetailPill(Icons.work_outline, roleLabel),
                      if (objectifCA != null)
                        _buildDetailPill(
                            Icons.trending_up, '${_amount(objectifCA)} TND'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('Informations', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.border),
                color: AppColors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildInfoRow(Icons.email_outlined, 'Email', email),
                  _buildDivider(),
                  _buildInfoRow(Icons.badge_outlined, 'Rôle', roleLabel),
                  if (objectifCA != null) ...[
                    _buildDivider(),
                    _buildInfoRow(Icons.trending_up, 'Objectif CA',
                        '${_amount(objectifCA)} TND'),
                  ],
                ],
              ),
            ),
            SizedBox(height: 28.h),
            OutlinedButton.icon(
              onPressed: () => _showChangePassword(context),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 52.h),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              icon: Icon(Icons.lock_outline_rounded, size: 18.sp, color: AppColors.primary),
              label: Text(
                'Changer mon mot de passe',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
            // Leaving the app is separated from the ordinary account actions and
            // reads as destructive, instead of sharing the primary button style.
            SizedBox(height: 28.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: Size(double.infinity, 52.h),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              icon: Icon(Icons.logout_rounded, size: 18.sp),
              label: Text('Se déconnecter', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  /// Signing out drops the session and any unsent work — confirm first.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez saisir à nouveau vos identifiants pour revenir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go(RouteNames.login);
  }

  /// Bottom sheet letting the commercial change their own password.
  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Widget _buildDetailPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: Colors.white),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted)),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 14.w, endIndent: 14.w);
  }
}

// ─── Changement de mot de passe (self-service) ────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  // One toggle per field: a single shared flag revealed all three at once, and
  // only the first field carried the control.
  final Map<String, bool> _obscured = {
    'current': true,
    'next': true,
    'confirm': true,
  };
  bool _saving = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_current.text.isEmpty) {
      setState(() => _error = 'Saisissez votre mot de passe actuel.');
      return;
    }
    if (_next.text == _current.text) {
      setState(() => _error =
          'Le nouveau mot de passe doit être différent de l\'actuel.');
      return;
    }
    if (_next.text.length < 8) {
      setState(() => _error = 'Le nouveau mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'Les deux mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _saving = true);
    final res = await ref.read(authProvider.notifier).changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    res.fold(
      (f) => setState(() => _error = f.message),
      (_) => setState(() => _done = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            if (_done) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 54.sp, color: AppColors.success),
                    SizedBox(height: 12.h),
                    Text('Mot de passe modifié',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6.h),
                    Text('Utilisez-le à votre prochaine connexion.',
                        style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Fermer',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('Changer mon mot de passe',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 4.h),
              Text('Votre mot de passe actuel est demandé par sécurité.',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
              SizedBox(height: 18.h),
              _field(_current, 'current', 'Mot de passe actuel'),
              SizedBox(height: 16.h),
              _field(_next, 'next', 'Nouveau mot de passe',
                  helper: '8 caractères minimum.'),
              SizedBox(height: 16.h),
              _field(_confirm, 'confirm', 'Confirmer le nouveau mot de passe',
                  action: TextInputAction.done),
              if (_error != null) ...[
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16.sp, color: AppColors.error),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(fontSize: 12.5.sp, color: AppColors.error)),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text('Valider',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String key,
    String label, {
    String? helper,
    TextInputAction action = TextInputAction.next,
  }) {
    final obscure = _obscured[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visible label: the field name used to live in the placeholder only,
        // so it vanished as soon as the user started typing.
        Padding(
          padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
        TextField(
          controller: c,
          obscureText: obscure,
          textInputAction: action,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 18.sp),
            suffixIcon: IconButton(
              tooltip: obscure ? 'Afficher' : 'Masquer',
              icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18.sp),
              onPressed: () => setState(() => _obscured[key] = !obscure),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        if (helper != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              helper,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}
