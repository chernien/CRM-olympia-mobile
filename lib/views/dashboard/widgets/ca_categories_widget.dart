import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/ca_categorie.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';

/// Revenue split by article category (Intérieur / Extérieur / Olybat).
/// Resolved server-side through Divalto: ENT → MOUV → ART → T012.
class CaCategoriesWidget extends ConsumerWidget {
  const CaCategoriesWidget({super.key});

  static Color _color(String key) {
    switch (key.toLowerCase()) {
      case 'interieur':
        return AppColors.segmentIntern;
      case 'exterieur':
        return AppColors.segmentExtern;
      case 'olybat':
        return AppColors.segmentOlybat;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider.select((s) => s.caCategories));

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par catégorie',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Intérieur · Extérieur · Olybat',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
          SizedBox(height: 14.h),
          if (data == null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (data.categories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.donut_large_outlined,
                        size: 32.r, color: AppColors.border),
                    SizedBox(height: 10.h),
                    Text(
                      'Aucune vente sur cette période',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Total
            Text(
              '${data.total} TND',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 12.h),
            // Stacked bar — proportions at a glance
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SizedBox(
                height: 10.h,
                child: Row(
                  children: [
                    for (final c in data.categories)
                      if (c.pct > 0)
                        Expanded(
                          flex: (c.pct * 10).round().clamp(1, 100000),
                          child: Container(color: _color(c.categorie)),
                        ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            // Detail per category
            for (final c in data.categories) ...[
              _row(c),
              SizedBox(height: 10.h),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(CaCategorie c) {
    final pctText = c.pct
        .toStringAsFixed(1)
        .replaceAll('.', ','); // French decimal comma
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: _color(c.categorie),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                c.libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${c.lignes} ligne${c.lignes > 1 ? 's' : ''}',
                style:
                    TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${c.montant} TND',
              // Long amounts used to push the percentage off the card edge.
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$pctText %',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: _color(c.categorie),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
