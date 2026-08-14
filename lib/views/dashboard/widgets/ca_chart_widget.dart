import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';

class CAChartWidget extends ConsumerWidget {
  const CAChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final periode = state.selectedPeriod;
    final caData = switch (periode) {
      PeriodType.mensuel => state.caMensuel,
      PeriodType.trimestriel => state.caTrimestriel,
      PeriodType.global => state.caGlobal,
    };
    final points = caData?.points ?? const [];

    // Grid step derived from the data. It was pinned at 20 000, so small
    // figures showed no grid at all and large ones drew hundreds of lines.
    final maxValue = points.fold<double>(
        0, (m, p) => p.value > m ? p.value : m);
    final gridStep = _gridStep(maxValue);

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
            'Évolution du CA',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            // Followed the data instead of claiming "6 derniers mois" even when
            // the quarterly period was selected.
            // Le backend renvoie toujours les 6 derniers mois comme série ;
            // seule l'assiette du TOTAL change avec la période.
            periode == PeriodType.global
                ? '6 derniers mois · en TND · total depuis le début'
                : 'Par mois · en TND',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 190.h,
            child: points.isNotEmpty
                ? BarChart(
                    BarChartData(
                      // Tapping a bar now names the period and the exact amount
                      // — the default tooltip printed a bare unlabelled number.
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.textPrimary,
                          tooltipBorderRadius: BorderRadius.circular(10),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                            '${points[group.x].label}\n',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: '${_plain(rod.toY)} TND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      barGroups: points
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.value,
                                  color: AppColors.primary,
                                  width: 18.w,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6.r),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < points.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    points[index].label,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        // Value axis: the chart previously had no scale at all,
                        // so bar heights could not be read as amounts.
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: gridStep,
                            reservedSize: 42.w,
                            getTitlesWidget: (value, meta) {
                              if (value <= 0) return const SizedBox();
                              return Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: Text(
                                  _compact(value),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: gridStep,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  )
                : _emptyState(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 32.r, color: AppColors.border),
          SizedBox(height: 10.h),
          Text(
            'Aucun chiffre sur cette période',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// A grid step that yields roughly 4 lines whatever the magnitude.
  static double _gridStep(double maxValue) {
    if (maxValue <= 0) return 1;
    final rough = maxValue / 4;
    final magnitude =
        math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (magnitude * m >= rough) return magnitude * m;
    }
    return magnitude * 10;
  }

  /// Axis labels only — amounts elsewhere stay raw and unrounded.
  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  /// Exact amount, no rounding — matches how CA is shown everywhere else.
  static String _plain(double v) {
    final s = v.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
