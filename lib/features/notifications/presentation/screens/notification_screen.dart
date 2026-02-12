import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/notifications/data/models/notification_model.dart';
import 'package:storelytics/features/notifications/data/repositories/notification_repository.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/theme/app_spacing.dart';
import 'package:storelytics/core/extensions.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      loading: () => const AppLoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (user) {
        if (user?.currentStoreId == null) {
          return const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.store,
              title: 'No store selected',
            ),
          );
        }

        final storeId = user!.currentStoreId!;
        final notificationsAsync = ref.watch(
          notificationStreamProvider(storeId),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              TextButton(
                onPressed:
                    () => ref
                        .read(notificationRepositoryProvider)
                        .markAllAsRead(storeId),
                child: const Text('Mark all read'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: notificationsAsync.when(
            loading: () => const AppLoadingWidget(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications',
                  subtitle: 'You are all caught up!',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _NotificationCard(notification: item, isDark: isDark);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;
  final bool isDark;

  const _NotificationCard({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color:
          notification.isRead
              ? Colors.transparent
              : (isDark ? Colors.white10 : Colors.blue.withValues(alpha: 0.05)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              notification.isRead
                  ? Colors.transparent
                  : AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.id);
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.createdAt.timeAgo,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing:
            !notification.isRead
                ? const CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.secondary,
                )
                : IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed:
                      () => ref
                          .read(notificationRepositoryProvider)
                          .deleteNotification(notification.id),
                ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.report_problem_rounded;
      case NotificationType.expiryWarning:
        return Icons.event_busy_rounded;
      case NotificationType.salesAlert:
        return Icons.shopping_cart_checkout_rounded;
      case NotificationType.systemUpdate:
        return Icons.system_update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return AppColors.warning;
      case NotificationType.expiryWarning:
        return AppColors.loss;
      case NotificationType.salesAlert:
        return AppColors.profit;
      case NotificationType.systemUpdate:
        return Colors.blue;
      default:
        return AppColors.secondary;
    }
  }
}
