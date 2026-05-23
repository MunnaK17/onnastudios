import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_item_model.dart';
import '../../data/repositories/interfaces/notification_repository.dart';
import '../../data/repositories/implementations/mock_notification_repository.dart';

/// Provider for NotificationRepository instance.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
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
  AsyncValue<List<NotificationItemModel>> build() => const AsyncValue.loading();

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

  Future<void> markAsRead(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
      await loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      await loadNotifications();
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
