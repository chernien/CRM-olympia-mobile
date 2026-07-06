import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final name = user?.fullName ?? 'Utilisateur';
    final roleLabel = user?.role == 'admin' ? 'Administrateur' : 'Commercial';
    final email = user?.email ?? 'Non renseigné';
    final objectifCA = user?.objectifCA;
    final initials = user != null && user.prenom.isNotEmpty && user.nom.isNotEmpty
        ? '${user.prenom[0]}${user.nom[0]}'.toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mon Profil')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
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
                      if (objectifCA != null) _buildDetailPill(Icons.trending_up, '${objectifCA.toStringAsFixed(0)} TND'),
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
                    _buildInfoRow(Icons.trending_up, 'Objectif CA', '${objectifCA.toStringAsFixed(0)} TND'),
                  ],
                ],
              ),
            ),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 52.h),
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
      subtitle: Text(value, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 14.w, endIndent: 14.w);
  }
}
