import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/task_card.dart';
import '../../providers/task_provider.dart';

class UpcomingTasksScreen extends ConsumerWidget {
  const UpcomingTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Tasks'),
      ),
      body: tasks.isEmpty
          ? const EmptyStateView(
              icon: LucideIcons.calendarCheck,
              title: 'No upcoming tasks',
              description: 'You have no future deadlines scheduled.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onToggleComplete: (val) {
                    ref.read(taskProvider.notifier).toggleComplete(task.id, val);
                  },
                  onTap: () {
                    ref.read(taskProvider.notifier).selectTask(task);
                    context.push('/task-details', extra: task);
                  },
                  onDelete: () => ref.read(taskProvider.notifier).moveToTrash(task.id),
                  onArchive: () => ref.read(taskProvider.notifier).archiveTask(task.id),
                );
              },
            ),
    );
  }
}
