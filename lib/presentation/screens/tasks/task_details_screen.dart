import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/animated_checkbox.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../team/invite_member_dialog.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late TaskModel _currentTask;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _toggleComplete(bool value) async {
    await ref.read(taskProvider.notifier).toggleComplete(_currentTask.id, value);
    setState(() {
      _currentTask = _currentTask.copyWith(
        status: value ? 'completed' : 'todo',
        completedAt: value ? DateTime.now() : null,
      );
    });
  }

  void _addSubtask() async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;

    final newSubtask = SubtaskModel(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      taskId: _currentTask.id,
      title: title,
      position: _currentTask.subtasks.length,
    );

    final updatedSubtasks = [..._currentTask.subtasks, newSubtask];
    final updated = _currentTask.copyWith(subtasks: updatedSubtasks);

    await ref.read(taskProvider.notifier).updateTask(updated);
    setState(() {
      _currentTask = updated;
      _subtaskController.clear();
    });
  }

  void _toggleSubtask(SubtaskModel subtask, bool value) async {
    final updatedList = _currentTask.subtasks.map((s) {
      if (s.id == subtask.id) {
        return s.copyWith(isCompleted: value);
      }
      return s;
    }).toList();

    final updated = _currentTask.copyWith(subtasks: updatedList);
    await ref.read(taskProvider.notifier).updateTask(updated);
    setState(() {
      _currentTask = updated;
    });
  }

  void _showAssigneePicker(BuildContext context, TaskModel liveTask) {
    final selectedIds = List<String>.from(liveTask.assigneeIds);
    final selectedNames = List<String>.from(liveTask.assigneeNames);
    final selectedAvatars = List<String>.from(liveTask.assigneeAvatars);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer(
          builder: (consumerCtx, ref, _) {
            final teamMembers = ref.watch(teamProvider);
            return StatefulBuilder(
              builder: (ctx, setSheetState) {
                final theme = Theme.of(ctx);
                final mediaQuery = MediaQuery.of(ctx);
                final bottomSafe = math.max(mediaQuery.viewPadding.bottom, mediaQuery.padding.bottom);
                final double bottomPadding = bottomSafe > 0 ? bottomSafe + 16 : 28.0;

                return Container(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.spacing24,
                    AppConstants.spacing20,
                    AppConstants.spacing24,
                    bottomPadding,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Assign Team Members',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton.icon(
                              onPressed: () => showInviteMemberDialog(
                                context: context,
                                ref: ref,
                                defaultProjectName: liveTask.projectName,
                              ),
                              icon: const Icon(LucideIcons.userPlus, size: 16),
                              label: const Text('Invite', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select members for this task.', style: theme.textTheme.bodySmall),
                            Text(
                              '${selectedIds.length} assigned',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.38,
                          ),
                          child: teamMembers.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Text('No team members found. Tap Invite to add one!'),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: teamMembers.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final member = teamMembers[index];
                                    final isSelected = selectedIds.contains(member.id);
                                    return CheckboxListTile(
                                      value: isSelected,
                                      secondary: AppAvatar(
                                        name: member.name,
                                        avatarUrl: member.avatarUrl,
                                        radius: 18,
                                      ),
                                      title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                        member.role,
                                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                      ),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          if (val == true) {
                                            selectedIds.add(member.id);
                                            selectedNames.add(member.name);
                                            selectedAvatars.add(member.avatarUrl);
                                          } else {
                                            selectedIds.remove(member.id);
                                            selectedNames.remove(member.name);
                                            selectedAvatars.remove(member.avatarUrl);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final updated = liveTask.copyWith(
                                assigneeIds: selectedIds,
                                assigneeNames: selectedNames,
                                assigneeAvatars: selectedAvatars,
                              );
                              await ref.read(taskProvider.notifier).updateTask(updated);
                              if (mounted) {
                                setState(() => _currentTask = updated);
                                Navigator.pop(sheetContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            ),
                            child: const Text('Save Assignees'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTasks = ref.watch(taskProvider).allTasks;
    final liveTask = allTasks.firstWhere((t) => t.id == _currentTask.id, orElse: () => _currentTask);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 20),
            onPressed: () => context.push('/edit-task', extra: liveTask),
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 20),
            onSelected: (val) async {
              if (val == 'archive') {
                await ref.read(taskProvider.notifier).archiveTask(liveTask.id);
                if (context.mounted) context.pop();
              } else if (val == 'delete') {
                await ref.read(taskProvider.notifier).moveToTrash(liveTask.id);
                if (context.mounted) context.pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(LucideIcons.archive, size: 16),
                    SizedBox(width: 8),
                    Text('Archive Task'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Move to Trash', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Header Status & Priority Row
          Row(
            children: [
              StatusBadge(status: liveTask.status),
              const SizedBox(width: 8),
              PriorityBadge(priority: liveTask.priority),
              const Spacer(),
              AnimatedCheckbox(
                isChecked: liveTask.isCompleted,
                onChanged: _toggleComplete,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            liveTask.title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              decoration: liveTask.isCompleted ? TextDecoration.lineThrough : null,
              color: liveTask.isCompleted
                  ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Due Date & Project Metadata
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 16),
                    const SizedBox(width: 10),
                    Text('Due Date', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      liveTask.dueDate != null ? DateFormatter.formatDate(liveTask.dueDate) : 'No due date',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (liveTask.dueTime != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 16),
                      const SizedBox(width: 10),
                      Text('Due Time', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(liveTask.dueTime!.format(context), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
                if (liveTask.projectName != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(LucideIcons.folder, size: 16),
                      const SizedBox(width: 10),
                      Text('Project', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(liveTask.projectName!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Assignees Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assignees', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => _showAssigneePicker(context, liveTask),
                icon: const Icon(LucideIcons.userPlus, size: 14),
                label: Text(liveTask.assigneeNames.isEmpty ? 'Assign' : 'Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            onTap: () => _showAssigneePicker(context, liveTask),
            child: liveTask.assigneeNames.isEmpty
                ? Row(
                    children: [
                      const Icon(LucideIcons.users, size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text('No one assigned yet. Tap to assign.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(liveTask.assigneeNames.length, (i) {
                      final name = liveTask.assigneeNames[i];
                      final avatar = i < liveTask.assigneeAvatars.length ? liveTask.assigneeAvatars[i] : null;
                      return Chip(
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar == null || avatar.isEmpty ? Text(name[0], style: const TextStyle(fontSize: 10)) : null,
                        ),
                        label: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 20),

          // Description
          if (liveTask.description.isNotEmpty) ...[
            Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Text(liveTask.description, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 24),
          ],

          // Subtasks Checklist Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtasks (${liveTask.completedSubtasksCount}/${liveTask.subtasks.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: () => context.push('/subtasks', extra: liveTask),
                icon: const Icon(LucideIcons.listTodo, size: 14),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subtasks progress bar
          if (liveTask.subtasks.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: liveTask.subtasksProgress,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.completed),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Subtask inline items
          ...liveTask.subtasks.map((st) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    AnimatedCheckbox(
                      isChecked: st.isCompleted,
                      onChanged: (val) => _toggleSubtask(st, val),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        st.title,
                        style: TextStyle(
                          decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                          color: st.isCompleted
                              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Quick Add Subtask Input
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  decoration: const InputDecoration(
                    hintText: 'Add a new subtask step...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addSubtask,
                icon: const Icon(LucideIcons.plus, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Action Shortcuts: Comments & Attachments
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () => context.push('/task-comments', extra: liveTask),
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.messageSquare, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comments', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${liveTask.commentsCount} comments', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  onTap: () => context.push('/task-attachments', extra: liveTask),
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.paperclip, size: 20, color: theme.colorScheme.secondary),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Files', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${liveTask.attachmentsCount} files', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
