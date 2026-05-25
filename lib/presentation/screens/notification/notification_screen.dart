import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/notification_item_model.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Header
            const _HeaderSection(),
            const SizedBox(height: AppSpacing.xl),
            // Notifications List
            const _NotificationsSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Updates', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Your latest studio news and reminders.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          // Mark all as read button
          notificationsAsync.when(
            data: (notifications) {
              final hasUnread = notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  ref
                      .read(notificationNotifierProvider.notifier)
                      .markAllAsRead();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  textStyle: AppTypography.labelCaps,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: const Text('Mark all read'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);

    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return const _EmptyNotifications();
        }
        return Column(
          children: notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final notification = entry.value;
            final isLast = index == notifications.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                bottom: isLast ? 0 : AppSpacing.sm,
              ),
              child: _NotificationCard(notification: notification),
            );
          }).toList(),
        );
      },
      loading: () => const _LoadingNotifications(),
      error: (e, st) => const _ErrorNotifications(),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.notification});

  final NotificationItemModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: notification.isRead
          ? Colors.transparent
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => _handleNotificationTap(context, ref),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColors.outlineVariant.withAlpha(77),
            ),
            boxShadow: notification.isRead ? null : AppShadows.subtle,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread Indicator
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    right: AppSpacing.sm,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconBackground(
                    notification.type,
                    notification.isRead,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type, notification.isRead),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // Message
                    Text(
                      notification.message,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Actions (only for unread)
                    if (!notification.isRead)
                      _NotificationActions(notification: notification),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref) {
    // Mark as read when tapped
    if (!notification.isRead) {
      ref
          .read(notificationNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on type
    switch (notification.type) {
      case NotificationType.classReminder:
      case NotificationType.bookingConfirmed:
        // Navigate to booking confirmation if we have booking info
        // For now, show a snackbar as placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification.title),
            backgroundColor: AppColors.surfaceContainerHigh,
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case NotificationType.packageExpiring:
      case NotificationType.promotion:
        // Navigate to package screen
        context.go(AppRoutes.package);
        break;
      default:
        // Just mark as read, no navigation
        break;
    }
  }

  IconData _getIcon(NotificationType type) {
    return switch (type) {
      NotificationType.classReminder => Icons.spa_outlined,
      NotificationType.bookingConfirmed => Icons.check_circle_outline,
      NotificationType.packageExpiring => Icons.warning_amber_outlined,
      NotificationType.creditRunningLow => Icons.monetization_on_outlined,
      NotificationType.promotion => Icons.campaign_outlined,
      NotificationType.scheduleUpdate => Icons.calendar_today_outlined,
    };
  }

  Color _getIconBackground(NotificationType type, bool isRead) {
    if (!isRead) {
      return switch (type) {
        NotificationType.classReminder => AppColors.secondaryContainer,
        NotificationType.bookingConfirmed => AppColors.secondaryContainer,
        NotificationType.packageExpiring => AppColors.errorContainer,
        NotificationType.creditRunningLow => AppColors.errorContainer,
        NotificationType.promotion => AppColors.tertiaryContainer,
        NotificationType.scheduleUpdate => AppColors.surfaceContainerHigh,
      };
    }
    return AppColors.surfaceVariant;
  }

  Color _getIconColor(NotificationType type, bool isRead) {
    if (!isRead) {
      return switch (type) {
        NotificationType.classReminder => AppColors.onSecondaryContainer,
        NotificationType.bookingConfirmed => AppColors.onSecondaryContainer,
        NotificationType.packageExpiring => AppColors.onErrorContainer,
        NotificationType.creditRunningLow => AppColors.onErrorContainer,
        NotificationType.promotion => AppColors.onTertiaryFixed,
        NotificationType.scheduleUpdate => AppColors.onSurfaceVariant,
      };
    }
    return AppColors.onSurfaceVariant;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({required this.notification});

  final NotificationItemModel notification;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('View details coming soon'),
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            textStyle: AppTypography.labelCaps,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 0,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('View'),
        ),
        const SizedBox(width: AppSpacing.md),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Action coming soon'),
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.outline,
            textStyle: AppTypography.labelCaps,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 0,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.notifications_none_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No notifications yet',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Updates from the studio will appear here',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingNotifications extends StatelessWidget {
  const _LoadingNotifications();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? AppSpacing.sm : 0),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ],
                    ),
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

class _ErrorNotifications extends StatelessWidget {
  const _ErrorNotifications();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load notifications',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
