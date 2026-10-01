import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/task_card.dart';
import '../../providers/task_provider.dart';
import '../../providers/filter_provider.dart';
import '../filters/filter_sheet.dart';
import 'create_task_sheet.dart';

class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(LucideIcons.slidersHorizontal, size: 20),
                if (filter.hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const FilterSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.archive, size: 20),
            onPressed: () => context.push('/archived-tasks'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () => context.push('/trash'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips summary if active
          if (filter.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filter.status != 'all')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text('Status: ${filter.status}'),
                          onDeleted: () => ref.read(filterProvider.notifier).setStatus('all'),
                        ),
                      ),
                    if (filter.priority != 'all')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text('Priority: ${filter.priority}'),
                          onDeleted: () => ref.read(filterProvider.notifier).setPriority('all'),
                        ),
                      ),
                    if (filter.projectId != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: const Text('Project Filter Active'),
                          onDeleted: () => ref.read(filterProvider.notifier).setProject(null),
                        ),
                      ),
                    ActionChip(
                      avatar: const Icon(LucideIcons.x, size: 12),
                      label: const Text('Clear All'),
                      onPressed: () => ref.read(filterProvider.notifier).reset(),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: tasks.isEmpty
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
                : RefreshIndicator(
                    onRefresh: () => ref.read(taskProvider.notifier).loadAll(),
                    child: ListView.builder(
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
                  ),
          ),
        ],
      ),
    );
  }
}
