import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models/project_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';
import 'glass_card.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.totalTasks = 0,
    this.completedTasks = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color pColor = theme.colorScheme.primary;
    if (project.color.startsWith('#')) {
      final hex = project.color.replaceAll('#', '');
      pColor = Color(int.parse('FF$hex', radix: 16));
    }

    final double progressVal = (project.progress / 100.0).clamp(0.0, 1.0);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.spacing16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: pColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: pColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Icon(
                    _resolveProjectIcon(project.icon),
                    size: 20,
                    color: pColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        project.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${project.progress}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: pColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(pColor),
            ),
          ),
          const SizedBox(height: 12),
          // Meta Footer: Task Count + Deadline
          Row(
            children: [
              Icon(LucideIcons.checkSquare, size: 13, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 5),
              Text(
                '$completedTasks / $totalTasks Tasks',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (project.deadline != null) ...[
                Icon(LucideIcons.clock, size: 13, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 5),
                Text(
                  DateFormatter.formatShortDate(project.deadline),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _resolveProjectIcon(String icon) {
    switch (icon) {
      case 'globe':
        return LucideIcons.globe;
      case 'shopping_bag':
        return LucideIcons.shoppingBag;
      case 'credit_card':
        return LucideIcons.creditCard;
      case 'book_open':
        return LucideIcons.bookOpen;
      case 'smile':
        return LucideIcons.smile;
      case 'code':
        return LucideIcons.code;
      case 'briefcase':
        return LucideIcons.briefcase;
      default:
        return LucideIcons.folder;
    }
  }
}
