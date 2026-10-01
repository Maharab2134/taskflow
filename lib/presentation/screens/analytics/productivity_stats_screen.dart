import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class ProductivityStatsScreen extends StatelessWidget {
  const ProductivityStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Statistics'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // Score Hero
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, AppColors.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '94',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Productivity Index', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Top 5% among engineering peers this week. Consistency is phenomenal.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dimensions Breakdown
          Text('Key Metrics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Task Completion Rate',
            value: '88%',
            progress: 0.88,
            color: AppColors.completed,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'On-Time Delivery',
            value: '95%',
            progress: 0.95,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Average Task Duration',
            value: '42 mins',
            progress: 0.70,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Weekly Consistency',
            value: '92%',
            progress: 0.92,
            color: AppColors.tertiary,
          ),
          const SizedBox(height: 24),

          // Best Focus Hours
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.zap, size: 18, color: AppColors.inProgress),
                    const SizedBox(width: 8),
                    Text('Peak Focus Window', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your highest task completion velocity occurs between 9:00 AM and 11:30 AM.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
