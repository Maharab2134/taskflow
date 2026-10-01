import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRepository _repo;

  @override
  NotificationState build() {
    _repo = ref.watch(notificationRepositoryProvider);
    Future.microtask(() => loadNotifications());
    return NotificationState(isLoading: true);
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    final list = await _repo.getNotifications();
    state = state.copyWith(notifications: list, isLoading: false);
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    state = state.copyWith(notifications: []);
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(NotificationNotifier.new);
