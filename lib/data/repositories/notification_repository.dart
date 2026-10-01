import '../../core/services/supabase_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'notif-1',
      userId: 'demo-user-12345',
      title: 'Welcome to TaskFlow!',
      message: 'Master your workflow with projects, subtasks, kanban boards, and analytics.',
      type: 'system',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'notif-2',
      userId: 'demo-user-12345',
      title: 'Deadline Approaching',
      message: 'Task "Design landing page hero section in Figma" is scheduled for today.',
      type: 'deadline_approaching',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'notif-3',
      userId: 'demo-user-12345',
      title: 'New Comment on Task',
      message: 'Elena Rostova commented on "Design landing page hero section in Figma".',
      type: 'comment_added',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: 'notif-4',
      userId: 'demo-user-12345',
      title: 'Task Assigned',
      message: 'You have been assigned to "Integrate Stripe payment checkout sheet".',
      type: 'task_assigned',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<NotificationModel>> getNotifications() async {
    final client = _supabase.client;
    final user = _supabase.currentUser;

    if (client != null && user != null && _supabase.isConfigured) {
      try {
        final res = await client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        return (res as List).map((i) => NotificationModel.fromJson(i)).toList();
      } catch (_) {}
    }

    if (_supabase.isConfigured) {
      return [];
    }

    return List.from(_notifications);
  }

  Future<void> markAsRead(String id) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('notifications').update({'is_read': true}).eq('id', id);
      } catch (_) {}
    }

    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  Future<void> clearAll() async {
    _notifications.clear();
  }
}
