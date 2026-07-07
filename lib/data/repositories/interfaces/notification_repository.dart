import '../../models/notification_item_model.dart';
import '../../models/app_enums.dart';

/// Repository interface for notification operations.
abstract class NotificationRepository {
  /// Get all notifications.
  Future<List<NotificationItemModel>> getAllNotifications();

  /// Get unread notifications.
  Future<List<NotificationItemModel>> getUnreadNotifications();

  /// Get unread count.
  Future<int> getUnreadCount();

  /// Create a new notification.
  Future<NotificationItemModel> createNotification({
    required String title,
    required String message,
    required NotificationType type,
  });

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read.
  Future<void> markAllAsRead();

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId);
}
