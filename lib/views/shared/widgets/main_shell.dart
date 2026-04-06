import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.dashboard)) return 0;
    if (location.startsWith(RouteNames.tasks)) return 1;
    if (location.startsWith(RouteNames.demandes)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.tasks);
      case 2:
        context.go(RouteNames.demandes);
      case 3:
        context.go(RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      // extendBody ensures the floating nav bar overlays the scrollable content
      extendBody: true, 
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 16.h),
          child: Container(
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.r, sigmaY: 15.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5.w),
                    borderRadius: BorderRadius.circular(35.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavBarItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Accueil',
                        isSelected: currentIndex == 0,
                        onTap: () => _onItemTapped(0, context),
                      ),
                      _NavBarItem(
                        icon: Icons.task_outlined,
                        activeIcon: Icons.task_rounded,
                        label: 'Tâches',
                        isSelected: currentIndex == 1,
                        onTap: () => _onItemTapped(1, context),
                      ),
                      _NavBarItem(
                        icon: Icons.description_outlined,
                        activeIcon: Icons.description_rounded,
                        label: 'Demandes',
                        isSelected: currentIndex == 2,
                        onTap: () => _onItemTapped(2, context),
                      ),
                      _NavBarItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                        isSelected: currentIndex == 3,
                        onTap: () => _onItemTapped(3, context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20.w : 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}