import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/app_toast.dart';
import '../../providers/task_provider.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trash = ref.watch(taskProvider).trashTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: trash.isEmpty
          ? EmptyStateView.trash()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              itemCount: trash.length,
              itemBuilder: (context, index) {
                final task = trash[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              if (task.projectName != null)
                                Text(
                                  task.projectName!,
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.rotateCcw, size: 18, color: AppColors.completed),
                          tooltip: 'Restore Task',
                          onPressed: () {
                            ref.read(taskProvider.notifier).restoreFromTrash(task.id);
                            AppToast.showSuccess(context, 'Restored "${task.title}"');
                          },
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 18, color: AppColors.error),
                          tooltip: 'Permanently Delete',
                          onPressed: () {
                            ref.read(taskProvider.notifier).permanentlyDelete(task.id);
                            AppToast.showInfo(context, 'Permanently deleted "${task.title}"');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
