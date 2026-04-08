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
    final caData = state.selectedPeriod == PeriodType.mensuel
        ? state.caMensuel
        : state.caTrimestriel;

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
            'Répartition CA',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _legendItem('Intern', AppColors.segmentIntern),
                SizedBox(width: 12.w),
                _legendItem('Extern', AppColors.segmentExtern),
                SizedBox(width: 12.w),
                _legendItem('Olybat', AppColors.segmentOlybat),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 190.h,
            child: caData != null && caData.points.isNotEmpty
                ? BarChart(
                    BarChartData(
                      barGroups: caData.points
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
                              if (index < caData.points.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    caData.points[index].label,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
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
                        horizontalInterval: 20000,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withValues(alpha: 0.5),
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Aucune donnée disponible',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
