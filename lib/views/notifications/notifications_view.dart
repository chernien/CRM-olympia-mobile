import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../viewmodels/notification_viewmodel.dart';

/// Écran Notifications — branché sur `GET /api/notifications`.
///
/// Les données factices ont disparu : ce que le commercial voit ici est
/// exactement ce que le backend a écrit en base au moment de l'événement métier.
/// FCM ne sert qu'à le réveiller ; cet écran reste juste même sans push.
class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).load();
    });
  }

  Future<void> _open(NotificationModel n) async {
    await ref.read(notificationProvider.notifier).markRead(n.id);
    if (!mounted) return;
    if (n.demandeId != null) {
      context.pushNamed(
        RouteNames.demandeDetail,
        pathParameters: {'id': n.demandeId!},
      );
    } else if (n.tacheId != null) {
      context.go(RouteNames.tasks);
    } else if (n.objectifId != null) {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final hasUnread = state.nonLues > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: hasUnread
                ? () => ref.read(notificationProvider.notifier).markAllRead()
                : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textSecondary,
              minimumSize: Size(48.w, 44.h),
            ),
            child: Text(
              'Tout lire',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(notificationProvider.notifier).load(),
            tooltip: 'Actualiser',
            color: AppColors.primary,
            icon: const Icon(Icons.refresh),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(notificationProvider.notifier).load(),
          color: AppColors.primary,
          child: state.isLoading && state.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.error != null && state.items.isEmpty
                  ? _buildErrorState(state.error!.message)
                  : state.items.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: EdgeInsets.all(16.r),
                          itemCount: state.items.length + 1,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildOverview(
                                  state.nonLues, state.items.length);
                            }
                            return _buildNotificationCard(
                                state.items[index - 1]);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildOverview(int unreadCount, int total) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.secondary.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_outlined,
                color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications récentes',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                SizedBox(height: 6.h),
                Text(
                  '$unreadCount non lues · $total affichées',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final unread = !notification.lu;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: AppColors.surface,
        border: Border.all(
          color: unread
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () => _open(notification),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(notification.titre,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                  if (unread)
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(notification.message,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                      height: 1.45)),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(notification.categorie,
                        style: TextStyle(
                            fontSize: 12.sp, color: AppColors.textSecondary)),
                  ),
                  Text(_relativeTime(notification.createdAt),
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // ListView (et non Center) pour que le pull-to-refresh reste possible à vide.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 80.h),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primaryGhost,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded,
                  size: 36.r, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text('Aucune notification',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text('Les alertes sur vos tâches et vos demandes apparaîtront ici.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMuted,
                    height: 1.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 80.h),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 36.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text('Notifications indisponibles',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMuted,
                    height: 1.5)),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).load(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ],
    );
  }

  /// « Il y a 2 h », « Hier », puis la date — en français.
  String _relativeTime(DateTime? date) {
    if (date == null) return '';
    final delta = DateTime.now().difference(date.toLocal());
    if (delta.inMinutes < 1) return "À l'instant";
    if (delta.inMinutes < 60) return 'Il y a ${delta.inMinutes} min';
    if (delta.inHours < 24) return 'Il y a ${delta.inHours} h';
    if (delta.inDays == 1) return 'Hier';
    if (delta.inDays < 30) return 'Il y a ${delta.inDays} jours';
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }
}
