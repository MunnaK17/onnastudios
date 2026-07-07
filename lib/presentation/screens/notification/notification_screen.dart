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
import '../../../shared/widgets/state/app_state_widgets.dart';

/// Provider for notification preferences (in-memory state for MVP).
/// In production, this should be persisted to Supabase.
final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);

class NotificationPreferences {
  const NotificationPreferences({
    this.bookingEnabled = true,
    this.reminderEnabled = true,
    this.creditEnabled = true,
    this.promotionEnabled = true,
  });

  final bool bookingEnabled;
  final bool reminderEnabled;
  final bool creditEnabled;
  final bool promotionEnabled;

  NotificationPreferences copyWith({
    bool? bookingEnabled,
    bool? reminderEnabled,
    bool? creditEnabled,
    bool? promotionEnabled,
  }) {
    return NotificationPreferences(
      bookingEnabled: bookingEnabled ?? this.bookingEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      creditEnabled: creditEnabled ?? this.creditEnabled,
      promotionEnabled: promotionEnabled ?? this.promotionEnabled,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() {
    return const NotificationPreferences();
  }

  void toggleBooking(bool value) {
    state = state.copyWith(bookingEnabled: value);
  }

  void toggleReminder(bool value) {
    state = state.copyWith(reminderEnabled: value);
  }

  void toggleCredit(bool value) {
    state = state.copyWith(creditEnabled: value);
  }

  void togglePromotion(bool value) {
    state = state.copyWith(promotionEnabled: value);
  }

  void resetToDefault() {
    state = const NotificationPreferences();
  }
}

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const _HeaderSection(),
              const SizedBox(height: AppSpacing.xl),
              const _NotificationPreferencesSection(),
              const SizedBox(height: AppSpacing.xl),
              const _NotificationsSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.onSurface,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Manage your notification preferences and view updates.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreferencesSection extends ConsumerWidget {
  const _NotificationPreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              children: [
                _PreferenceToggle(
                  icon: Icons.check_circle_outline,
                  title: 'Booking Confirmations',
                  subtitle: 'Get notified when booking is successful',
                  value: preferences.bookingEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleBooking(value);
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.outlineVariant.withAlpha(128),
                  indent: AppSpacing.screenPadding,
                  endIndent: AppSpacing.screenPadding,
                ),
                _PreferenceToggle(
                  icon: Icons.schedule_outlined,
                  title: 'Class Reminders',
                  subtitle: 'Reminders before your scheduled classes',
                  value: preferences.reminderEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleReminder(value);
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.outlineVariant.withAlpha(128),
                  indent: AppSpacing.screenPadding,
                  endIndent: AppSpacing.screenPadding,
                ),
                _PreferenceToggle(
                  icon: Icons.monetization_on_outlined,
                  title: 'Credit Alerts',
                  subtitle: 'Low credit and balance warnings',
                  value: preferences.creditEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleCredit(value);
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.outlineVariant.withAlpha(128),
                  indent: AppSpacing.screenPadding,
                  endIndent: AppSpacing.screenPadding,
                ),
                _PreferenceToggle(
                  icon: Icons.campaign_outlined,
                  title: 'Promotions',
                  subtitle: 'Special offers and studio updates',
                  value: preferences.promotionEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesProvider.notifier)
                        .togglePromotion(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  const _PreferenceToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Updates', style: AppTypography.h3),
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
                    ),
                    child: const Text('Mark all read'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: AppEmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'No notifications yet',
                  subtitle: 'Updates from the studio will appear here',
                ),
              );
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
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: AppLoadingState(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: AppErrorState(
              onRetry: () => ref.invalidate(notificationNotifierProvider),
            ),
          ),
        ),
      ],
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
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    right: AppSpacing.sm,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconBackground(notification.type, notification.isRead),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type, notification.isRead),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      notification.message,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _NotificationActions(notification: notification),
                    ],
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
    if (!notification.isRead) {
      ref
          .read(notificationNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    switch (notification.type) {
      case NotificationType.classReminder:
      case NotificationType.bookingConfirmed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification.title),
            backgroundColor: AppColors.surfaceContainerHigh,
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      default:
        break;
    }
  }

  IconData _getIcon(NotificationType type) {
    return switch (type) {
      NotificationType.classReminder => Icons.spa_outlined,
      NotificationType.bookingConfirmed => Icons.check_circle_outline,
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
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}

class _NotificationActions extends ConsumerWidget {
  const _NotificationActions({required this.notification});

  final NotificationItemModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            ref
                .read(notificationNotifierProvider.notifier)
                .markAsRead(notification.id);
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
            ref
                .read(notificationNotifierProvider.notifier)
                .deleteNotification(notification.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notification dismissed'),
                backgroundColor: AppColors.secondary,
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
