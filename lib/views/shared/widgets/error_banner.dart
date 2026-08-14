import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// Inline error strip shown above stale content when a refresh fails.
///
/// Single implementation shared by the dashboard, the task list and the demande
/// list — they previously each carried a private copy that drifted apart.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  /// Outer margin. Screens that already pad their column pass [EdgeInsets.zero].
  final EdgeInsetsGeometry margin;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 4.w, 4.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                message,
                style: TextStyle(fontSize: 13.sp, color: AppColors.error),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Full-height target: the retry action used to be a 4 px-padded label.
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              minimumSize: Size(64.w, 44.h),
              tapTargetSize: MaterialTapTargetSize.padded,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Réessayer',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
