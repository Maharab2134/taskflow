import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'task_assigned':
        return LucideIcons.userCheck;
      case 'task_completed':
        return LucideIcons.checkCircle;
      case 'task_overdue':
        return LucideIcons.alertTriangle;
      case 'comment_added':
        return LucideIcons.messageSquare;
      case 'mention':
        return LucideIcons.atSign;
      case 'project_update':
        return LucideIcons.folderSync;
      case 'reminder':
        return LucideIcons.bellRing;
      case 'deadline_approaching':
        return LucideIcons.clock;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'task_completed':
        return AppColors.completed;
      case 'task_overdue':
        return AppColors.error;
      case 'comment_added':
      case 'mention':
        return AppColors.secondary;
      case 'deadline_approaching':
        return AppColors.inProgress;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationProvider);
    final notifications = notifState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 18),
              onPressed: () => ref.read(notificationProvider.notifier).clearAll(),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? EmptyStateView.notifications()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final color = _getColorForType(notif.type);
                final icon = _getIconForType(notif.type);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    onTap: () {
                      ref.read(notificationProvider.notifier).markAsRead(notif.id);
                    },
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatTime(notif.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: notif.isRead ? null : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
