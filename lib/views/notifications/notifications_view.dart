import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final List<_NotificationItem> _initialNotifications = const [
    _NotificationItem(
      title: 'Nouvelle tâche ajoutée',
      message: 'Votre demande auprès de Peintures Atlas a été planifiée.',
      timestamp: 'Il y a 2h',
      category: 'Tâche',
      unread: true,
    ),
    _NotificationItem(
      title: 'Demande validée',
      message: 'La demande D-2026-0003 a été validée par l’administrateur.',
      timestamp: 'Hier',
      category: 'Demande',
      unread: true,
    ),
    _NotificationItem(
      title: 'Nouveau rappel',
      message: 'N’oubliez pas votre visite à Brico Déco Casablanca demain.',
      timestamp: '2 jours',
      category: 'Rappel',
      unread: false,
    ),
  ];

  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(_initialNotifications);
  }

  void _clearAll() {
    setState(() => _notifications.clear());
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => _NotificationItem(
                title: n.title,
                message: n.message,
                timestamp: n.timestamp,
                category: n.category,
                unread: false,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _notifications.where((n) => n.unread).isEmpty ? null : _markAllAsRead,
            child: Text(
              'Tout lire',
              style: TextStyle(
                color: _notifications.where((n) => n.unread).isEmpty ? AppColors.textSecondary : Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: _notifications.isEmpty ? null : _clearAll,
            child: Text('Tout effacer', style: TextStyle(color: _notifications.isEmpty ? AppColors.textSecondary : Colors.white, fontSize: 14.sp)),
          ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: _notifications.length + 1,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildOverview();
                  final notification = _notifications[index - 1];
                  return _buildNotificationCard(notification);
                },
              ),
      ),
    );
  }

  Widget _buildOverview() {
    final unreadCount = _notifications.where((n) => n.unread).length;
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
            child: Icon(Icons.notifications_active_outlined, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications récentes', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 6.h),
                Text(
                  '$unreadCount non lues · ${_notifications.length} totales',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem notification) {
    return Dismissible(
      key: ValueKey('${notification.title}-${notification.timestamp}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _notifications.remove(notification);
        });
      },
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(18.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 18.w),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 20.sp),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: AppColors.surface,
          border: Border.all(color: notification.unread ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {
            if (!notification.unread) return;
            setState(() {
              final idx = _notifications.indexOf(notification);
              if (idx != -1) {
                _notifications[idx] = _NotificationItem(
                  title: notification.title,
                  message: notification.message,
                  timestamp: notification.timestamp,
                  category: notification.category,
                  unread: false,
                );
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                    if (notification.unread)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(notification.message, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(notification.category, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    ),
                    Text(notification.timestamp, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 18.h),
            Text('Toutes les notifications sont effacées', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text('Vous recevrez les nouvelles alertes dès qu’elles seront disponibles.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String timestamp;
  final String category;
  final bool unread;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.unread = false,
  });
}
