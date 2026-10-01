import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/task_card.dart';
import '../../providers/task_provider.dart';

class ArchivedTasksScreen extends ConsumerWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(taskProvider).archivedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Tasks'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: archived.isEmpty
          ? EmptyStateView.archive()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              itemCount: archived.length,
              itemBuilder: (context, index) {
                final task = archived[index];
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
                );
              },
            ),
    );
  }
}
