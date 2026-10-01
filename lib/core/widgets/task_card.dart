import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models/task_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import 'animated_checkbox.dart';
import 'glass_card.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = DateFormatter.isOverdue(task.dueDate) && !task.isCompleted;

    Color? projectColor;
    if (task.projectColor != null && task.projectColor!.startsWith('#')) {
      final hex = task.projectColor!.replaceAll('#', '');
      projectColor = Color(int.parse('FF$hex', radix: 16));
    }

    final card = AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: task.isCompleted ? 0.65 : 1.0,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCheckbox(
                  isChecked: task.isCompleted,
                  onChanged: onToggleComplete,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PriorityBadge(priority: task.priority),
                if (onDelete != null || onArchive != null) ...[
                  const SizedBox(width: 2),
                  PopupMenuButton<String>(
                    icon: Icon(
                      LucideIcons.moreVertical,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 140),
                    onSelected: (val) {
                      if (val == 'archive') {
                        onArchive?.call();
                      } else if (val == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (onArchive != null)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(LucideIcons.archive, size: 14),
                              SizedBox(width: 8),
                              Text('Archive Task'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Move to Trash', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Bottom Meta Row: Project Tag, Due Date, Subtask Count
            Row(
              children: [
                if (task.projectName != null && task.projectName!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (projectColor ?? theme.colorScheme.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: projectColor ?? theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          task.projectName!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: projectColor ?? theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (task.dueDate != null) ...[
                  Icon(
                    LucideIcons.calendar,
                    size: 13,
                    color: isOverdue ? AppColors.error : theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.getRelativeDueDate(task.dueDate),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                      color: isOverdue ? AppColors.error : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
                if (task.assigneeNames.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildAssigneeAvatars(theme),
                ],
                const Spacer(),
                if (task.subtasks.isNotEmpty) ...[
                  Icon(
                    LucideIcons.checkCheck,
                    size: 13,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.completedSubtasksCount}/${task.subtasks.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (onDelete != null || onArchive != null) {
      return Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.inProgress.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.archive, color: AppColors.inProgress, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Archive',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF261C24) : const Color(0xFFFDE8E8),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Move to Trash',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 16),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Confirm delete
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Move to Trash?'),
                content: Text('Are you sure you want to move "${task.title}" to trash?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Move to Trash'),
                  ),
                ],
              ),
            );
            return confirm ?? false;
          }
          return true;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            onArchive?.call();
          } else {
            onDelete?.call();
          }
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildAssigneeAvatars(ThemeData theme) {
    final avatars = task.assigneeAvatars;
    final names = task.assigneeNames;
    if (names.isEmpty && avatars.isEmpty) return const SizedBox.shrink();

    final maxVisible = 3;
    final visibleCount = names.length > maxVisible ? maxVisible : names.length;
    final extraCount = names.length - visibleCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 18,
          width: 18.0 + (visibleCount - 1) * 12.0,
          child: Stack(
            children: List.generate(visibleCount, (i) {
              final avatar = i < avatars.length ? avatars[i] : null;
              final name = names[i];
              return Positioned(
                left: i * 12.0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                  ),
                  child: ClipOval(
                    child: avatar != null && avatar.isNotEmpty
                        ? Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _avatarInitial(name),
                          )
                        : _avatarInitial(name),
                  ),
                ),
              );
            }),
          ),
        ),
        if (extraCount > 0) ...[
          const SizedBox(width: 3),
          Text(
            '+$extraCount',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _avatarInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFF6366F1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
