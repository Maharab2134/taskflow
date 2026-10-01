import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'todo':
        return AppColors.todo;
      case 'in_progress':
        return AppColors.inProgress;
      case 'review':
        return AppColors.inReview;
      case 'completed':
        return AppColors.completed;
      case 'archived':
        return AppColors.archived;
      default:
        return AppColors.todo;
    }
  }

  String _getFormattedStatus() {
    switch (status.toLowerCase()) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'completed':
        return 'Completed';
      case 'archived':
        return 'Archived';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            _getFormattedStatus(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
