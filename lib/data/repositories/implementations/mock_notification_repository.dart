import '../../models/notification_item_model.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/notification_repository.dart';

/// Mock implementation of NotificationRepository.
class MockNotificationRepository implements NotificationRepository {
  final List<NotificationItemModel> _notifications =
      List<NotificationItemModel>.from(MockOnnaData.notifications);

  @override
  Future<List<NotificationItemModel>> getAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List<NotificationItemModel>.from(_notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<NotificationItemModel>> getUnreadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notifications.where((n) => !n.isRead).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationItemModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationItemModel(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          isRead: true,
          createdAt: _notifications[i].createdAt,
        );
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _notifications.removeWhere((n) => n.id == notificationId);
  }
}