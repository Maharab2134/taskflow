import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
        return AppColors.priorityMedium;
      case 'high':
        return AppColors.priorityHigh;
      case 'urgent':
        return AppColors.priorityUrgent;
      default:
        return AppColors.priorityMedium;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority.toLowerCase()) {
      case 'low':
        return LucideIcons.arrowDown;
      case 'medium':
        return LucideIcons.equal;
      case 'high':
        return LucideIcons.arrowUp;
      case 'urgent':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.equal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    final icon = _getPriorityIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
