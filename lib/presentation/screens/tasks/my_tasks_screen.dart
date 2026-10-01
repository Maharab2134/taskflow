import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/task_card.dart';
import '../../providers/task_provider.dart';
import 'create_task_sheet.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider).allTasks;
    final activeTasks = allTasks.where((t) => !t.isCompleted).toList();
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeTasks.length})'),
            Tab(text: 'Completed (${completedTasks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tasks
          activeTasks.isEmpty
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
                  itemCount: activeTasks.length,
                  itemBuilder: (context, index) {
                    final task = activeTasks[index];
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

          // Completed Tasks
          completedTasks.isEmpty
              ? const EmptyStateView(
                  icon: LucideIcons.checkCheck,
                  title: 'No completed tasks yet',
                  description: 'Finished tasks will appear here for your productivity record.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
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
        ],
      ),
    );
  }
}
