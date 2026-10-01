import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_constants.dart';
import 'app_button.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  factory EmptyStateView.tasks({VoidCallback? onAddTask}) {
    return EmptyStateView(
      icon: LucideIcons.checkSquare,
      title: 'No tasks scheduled',
      description: 'You are completely clear. Enjoy your free time or add a new goal.',
      actionLabel: 'Create Task',
      onAction: onAddTask,
    );
  }

  factory EmptyStateView.projects({VoidCallback? onAddProject}) {
    return EmptyStateView(
      icon: LucideIcons.folderPlus,
      title: 'No projects yet',
      description: 'Create your first project and start organizing your team and tasks.',
      actionLabel: 'New Project',
      onAction: onAddProject,
    );
  }

  factory EmptyStateView.notifications() {
    return const EmptyStateView(
      icon: LucideIcons.bellOff,
      title: 'You\'re all caught up',
      description: 'No new notifications right now. We\'ll notify you when updates occur.',
    );
  }

  factory EmptyStateView.search() {
    return const EmptyStateView(
      icon: LucideIcons.search,
      title: 'No matching results',
      description: 'Try refining your search keyword or clearing active filters.',
    );
  }

  factory EmptyStateView.trash() {
    return const EmptyStateView(
      icon: LucideIcons.trash2,
      title: 'Trash is empty',
      description: 'Deleted tasks will appear here before being permanently cleared.',
    );
  }

  factory EmptyStateView.archive() {
    return const EmptyStateView(
      icon: LucideIcons.archive,
      title: 'No archived tasks',
      description: 'Tasks you archive for reference will be stored safely here.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = iconColor ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing32, vertical: AppConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: primary.withOpacity(0.18), width: 1.5),
              ),
              child: Icon(
                icon,
                size: 32,
                color: primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppConstants.spacing24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: LucideIcons.plus,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
