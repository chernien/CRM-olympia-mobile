import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';

class DemandeTypeSelectionView extends StatelessWidget {
  const DemandeTypeSelectionView({super.key});

  static const _types = [
    (1, "Demande d'échantillons", "Commande d'échantillons produit pour présentation client", Icons.colorize_outlined, AppColors.primary),
    (2, 'Échantillons avec application', "Échantillons + intervention d'un applicateur terrain", Icons.brush_outlined, AppColors.secondary),
    (3, 'Réclamation', 'Signalement d\'un problème produit en 4 phases', Icons.report_problem_outlined, AppColors.primary),
    (4, 'Création nouveau client', 'Ouverture d\'un compte client dans le système', Icons.person_add_outlined, AppColors.secondary),
    (5, 'Renouvellement showroom', 'Mise à jour des produits exposés en showroom', Icons.store_outlined, AppColors.primary),
    (6, 'Demande de formation', 'Formation technique pour l\'équipe ou le client', Icons.school_outlined, AppColors.secondary),
    (7, 'Assistance chantier', 'Intervention technique sur un chantier en cours', Icons.construction_outlined, AppColors.primary),
    (8, 'Machine à teinter', 'Demande d\'installation ou maintenance machine', Icons.precision_manufacturing_outlined, AppColors.secondary),
    (9, 'Accessoires marketing', 'Commande de supports et outils marketing', Icons.campaign_outlined, AppColors.primary),
  ];

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
            Text('Choisissez le type', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: _types.length,
          itemBuilder: (context, index) {
            final t = _types[index];
            return _TypeListTile(
              index: index + 1,
              id: t.$1,
              label: t.$2,
              subtitle: t.$3,
              icon: t.$4,
              color: t.$5,
            );
          },
        ),
      ),
    );
  }
}

class _TypeListTile extends StatelessWidget {
  final int index;
  final int id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TypeListTile({
    required this.index,
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        RouteNames.demandeForm,
        pathParameters: {'type': id.toString()},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => context.goNamed(
              RouteNames.demandeForm,
              pathParameters: {'type': id.toString()},
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Stack(
                      children: [
                        Center(child: Icon(icon, color: color, size: 24.r)),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Arrow
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.arrow_forward_ios, size: 14.r, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
