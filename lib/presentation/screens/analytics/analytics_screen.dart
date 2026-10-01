import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allTasks = ref.watch(taskProvider).allTasks;
    final allProjects = ref.watch(projectProvider).projects;

    final totalCount = allTasks.length;
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final overdueCount = allTasks.where((t) {
      if (t.dueDate == null || t.isCompleted) return false;
      return t.dueDate!.isBefore(DateTime.now());
    }).length;

    final double completionRate = totalCount == 0 ? 0 : (completedCount / totalCount) * 100;

    // Priority counts for PieChart
    final lowCount = allTasks.where((t) => t.priority == 'low').length;
    final medCount = allTasks.where((t) => t.priority == 'medium').length;
    final highCount = allTasks.where((t) => t.priority == 'high').length;
    final urgentCount = allTasks.where((t) => t.priority == 'urgent').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trendingUp, size: 20),
            onPressed: () => context.push('/productivity-stats'),
            tooltip: 'Productivity Statistics',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // 4 Grid KPI Cards
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Completed',
                  value: '$completedCount',
                  icon: LucideIcons.checkCircle2,
                  color: AppColors.completed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  title: 'Completion Rate',
                  value: '${completionRate.toInt()}%',
                  icon: LucideIcons.percent,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Total Created',
                  value: '$totalCount',
                  icon: LucideIcons.layers,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  title: 'Overdue Tasks',
                  value: '$overdueCount',
                  icon: LucideIcons.alertTriangle,
                  color: overdueCount > 0 ? AppColors.error : AppColors.completed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Productivity Trend Line Chart
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Productivity Velocity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.completed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.arrowUpRight, size: 12, color: AppColors.completed),
                          SizedBox(width: 4),
                          Text('+18% vs last week', style: TextStyle(color: AppColors.completed, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (val.toInt() >= 0 && val.toInt() < labels.length) {
                                return Text(labels[val.toInt()], style: theme.textTheme.bodySmall?.copyWith(fontSize: 10));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 4),
                            FlSpot(2, 6),
                            FlSpot(3, 5),
                            FlSpot(4, 8),
                            FlSpot(5, 7),
                            FlSpot(6, 9),
                          ],
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Priority Distribution Pie Chart
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tasks by Priority', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 36,
                            sections: [
                              PieChartSectionData(value: (urgentCount == 0 ? 1 : urgentCount).toDouble(), color: AppColors.priorityUrgent, radius: 20, showTitle: false),
                              PieChartSectionData(value: (highCount == 0 ? 2 : highCount).toDouble(), color: AppColors.priorityHigh, radius: 20, showTitle: false),
                              PieChartSectionData(value: (medCount == 0 ? 4 : medCount).toDouble(), color: AppColors.priorityMedium, radius: 20, showTitle: false),
                              PieChartSectionData(value: (lowCount == 0 ? 2 : lowCount).toDouble(), color: AppColors.priorityLow, radius: 20, showTitle: false),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(color: AppColors.priorityUrgent, label: 'Urgent ($urgentCount)'),
                          _LegendItem(color: AppColors.priorityHigh, label: 'High ($highCount)'),
                          _LegendItem(color: AppColors.priorityMedium, label: 'Medium ($medCount)'),
                          _LegendItem(color: AppColors.priorityLow, label: 'Low ($lowCount)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Project Progress Overview
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project Milestones', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                ...allProjects.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text('${p.progress}%', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p.progress / 100.0,
                            minHeight: 6,
                            backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
