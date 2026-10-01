import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/task_card.dart';
import '../../providers/task_provider.dart';
import 'create_task_sheet.dart';

class TodayTasksScreen extends ConsumerWidget {
  const TodayTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: tasks.isEmpty
          ? EmptyStateView.tasks(
              onAddTask: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const CreateTaskSheet(),
                );
              },
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
