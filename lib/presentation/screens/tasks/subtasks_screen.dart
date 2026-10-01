import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/animated_checkbox.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';

class SubtasksScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const SubtasksScreen({super.key, required this.task});

  @override
  ConsumerState<SubtasksScreen> createState() => _SubtasksScreenState();
}

class _SubtasksScreenState extends ConsumerState<SubtasksScreen> {
  final TextEditingController _inputController = TextEditingController();
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addSubtask() async {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      await ref.read(taskProvider.notifier).addSubtask(_task.id, text);
      _inputController.clear();
      final updated = await ref.read(taskRepositoryProvider).getTaskById(_task.id);
      if (updated != null && mounted) setState(() => _task = updated);
    }
  }

  void _toggleSubtask(String subtaskId, bool isCompleted) async {
    await ref.read(taskProvider.notifier).toggleSubtask(_task.id, subtaskId, isCompleted);
    final updated = await ref.read(taskRepositoryProvider).getTaskById(_task.id);
    if (updated != null && mounted) setState(() => _task = updated);
  }

  void _deleteSubtask(String subtaskId) async {
    await ref.read(taskProvider.notifier).deleteSubtask(_task.id, subtaskId);
    final updated = await ref.read(taskRepositoryProvider).getTaskById(_task.id);
    if (updated != null && mounted) setState(() => _task = updated);
  }

  void _reorderSubtasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _task.subtasks.removeAt(oldIndex);
      _task.subtasks.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completedCount = _task.completedSubtasksCount;
    final totalCount = _task.subtasks.length;
    final double progress = _task.subtasksProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtasks Checklist'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Animated Progress Header Card
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: GlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedCount / $totalCount Completed',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppColors.completed,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.completed),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reorderable Subtasks List
          Expanded(
            child: _task.subtasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.listTodo, size: 40, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(height: 12),
                        Text('No subtasks yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Break this task down into manageable action steps below.', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _task.subtasks.length,
                    onReorder: _reorderSubtasks,
                    itemBuilder: (context, index) {
                      final st = _task.subtasks[index];
                      return Padding(
                        key: ValueKey(st.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              AnimatedCheckbox(
                                isChecked: st.isCompleted,
                                onChanged: (val) => _toggleSubtask(st.id, val),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  st.title,
                                  style: TextStyle(
                                    decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                                    color: st.isCompleted ? theme.textTheme.bodySmall?.color : null,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                                onPressed: () => _deleteSubtask(st.id),
                              ),
                              const Icon(LucideIcons.gripVertical, size: 16, color: AppColors.archived),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Input bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Add an action step...',
                        prefixIcon: Icon(LucideIcons.plus, size: 16),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _addSubtask,
                    icon: const Icon(LucideIcons.arrowUp, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
