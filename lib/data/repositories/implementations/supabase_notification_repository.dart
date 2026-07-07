import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_enums.dart';
import '../../models/notification_item_model.dart';
import '../interfaces/notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user.id;
  }

  NotificationItemModel _mapNotification(Map<String, dynamic> data) {
    return NotificationItemModel(
      id: data['id'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationType.values.byName(data['type'] as String),
      isRead: (data['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<List<NotificationItemModel>> getAllNotifications() async {
    final userId = _currentUserId;
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map(_mapNotification).toList();
  }

  @override
  Future<List<NotificationItemModel>> getUnreadNotifications() async {
    final userId = _currentUserId;
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);
    return data.map(_mapNotification).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final unread = await getUnreadNotifications();
    return unread.length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final userId = _currentUserId;
    await _client
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', userId);
  }

  @override
  Future<NotificationItemModel> createNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final userId = _currentUserId;

    final data = await _client
        .from('notifications')
        .insert({
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type.name,
          'is_read': false,
        })
        .select()
        .single();

    return _mapNotification(data);
  }
}
