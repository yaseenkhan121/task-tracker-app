import 'package:flutter/material.dart';
import 'package:intern_task_tracker/core/constants/app_colors.dart';
import 'package:intern_task_tracker/models/task_model.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    late final IconData icon;

    switch (status) {
      case TaskStatus.pending:
        color = AppColors.pendingOrange;
        label = 'Pending';
        icon = Icons.hourglass_empty_rounded;
        break;
      case TaskStatus.inProgress:
        color = AppColors.inProgressBlue;
        label = 'In Progress';
        icon = Icons.autorenew_rounded;
        break;
      case TaskStatus.review:
        color = AppColors.reviewPurple;
        label = 'In Review';
        icon = Icons.find_in_page_rounded;
        break;
      case TaskStatus.completed:
        color = AppColors.completedGreen;
        label = 'Completed';
        icon = Icons.check_circle_rounded;
        break;
      case TaskStatus.rejected:
        color = AppColors.rejectedRed;
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;

    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        label = 'Low';
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        label = 'Medium';
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        label = 'High';
        break;
      case TaskPriority.critical:
        color = AppColors.priorityCritical;
        label = 'Critical';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
