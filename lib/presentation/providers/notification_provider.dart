import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_enums.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/repositories/interfaces/notification_repository.dart';
import '../../data/repositories/implementations/supabase_notification_repository.dart';

/// Provider for NotificationRepository instance.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SupabaseNotificationRepository();
});

/// Provider for all notifications.
final allNotificationsProvider = FutureProvider<List<NotificationItemModel>>((
  ref,
) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getAllNotifications();
});

/// Provider for unread notifications.
final unreadNotificationsProvider = FutureProvider<List<NotificationItemModel>>(
  (ref) async {
    final repository = ref.watch(notificationRepositoryProvider);
    return repository.getUnreadNotifications();
  },
);

/// Provider for unread count.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

/// Notification state notifier using Riverpod 3.x Notifier.
class NotificationNotifier
    extends Notifier<AsyncValue<List<NotificationItemModel>>> {
  @override
  AsyncValue<List<NotificationItemModel>> build() {
    Future.microtask(loadNotifications);
    return const AsyncValue.loading();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await ref
          .read(notificationRepositoryProvider)
          .getAllNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create a new notification and refresh the list.
  Future<NotificationItemModel> createNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    try {
      final notification = await ref
          .read(notificationRepositoryProvider)
          .createNotification(
            title: title,
            message: message,
            type: type,
          );
      await loadNotifications();
      _refreshDerivedProviders();
      return notification;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Create booking confirmed notification.
  Future<NotificationItemModel> createBookingConfirmedNotification({
    required String className,
  }) async {
    return createNotification(
      title: 'Booking Confirmed! 🎉',
      message: 'Your spot for $className has been successfully booked. See you in the studio!',
      type: NotificationType.bookingConfirmed,
    );
  }

  /// Create credit low warning notification.
  Future<NotificationItemModel> createCreditLowNotification({
    required int remainingCredits,
  }) async {
    return createNotification(
      title: 'Credit Running Low ⚠️',
      message: 'You only have $remainingCredits credits left. Consider topping up to keep booking your favorite classes.',
      type: NotificationType.creditRunningLow,
    );
  }

  /// Create credit depleted notification.
  Future<NotificationItemModel> createCreditDepletedNotification() async {
    return createNotification(
      title: 'Credits Depleted 💳',
      message: 'You have no credits remaining. Top up now to continue booking classes!',
      type: NotificationType.creditRunningLow,
    );
  }

  /// Create class reminder notification.
  Future<NotificationItemModel> createClassReminderNotification({
    required String className,
    required String timeUntilClass,
  }) async {
    return createNotification(
      title: 'Class Starting Soon 🧘',
      message: '$className starts in $timeUntilClass. Don\'t forget your mat and water bottle!',
      type: NotificationType.classReminder,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
      await loadNotifications();
      _refreshDerivedProviders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      await loadNotifications();
      _refreshDerivedProviders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ref
          .read(notificationRepositoryProvider)
          .deleteNotification(notificationId);
      await loadNotifications();
      _refreshDerivedProviders();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _refreshDerivedProviders() {
    ref.invalidate(allNotificationsProvider);
    ref.invalidate(unreadNotificationsProvider);
    ref.invalidate(unreadCountProvider);
  }
}

/// NotifierProvider for notification state.
final notificationNotifierProvider =
    NotifierProvider<
      NotificationNotifier,
      AsyncValue<List<NotificationItemModel>>
    >(() {
      return NotificationNotifier();
    });
