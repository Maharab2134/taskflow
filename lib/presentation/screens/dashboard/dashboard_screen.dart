import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/project_card.dart';
import '../../../core/widgets/taskflow_logo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/notification_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final taskState = ref.watch(taskProvider);
    final projectState = ref.watch(projectProvider);
    final unreadNotifs = ref.watch(notificationProvider).unreadCount;

    final profile = ref.watch(profileProvider).asData?.value ?? authState.profile;
    final userName = profile?.fullName ?? 'Alex';
    final userAvatarUrl = profile?.avatarUrl;
    final allTasks = taskState.allTasks;

    // Filter today's tasks
    final now = DateTime.now();
    final todayTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();

    final todayCompleted = todayTasks.where((t) => t.isCompleted).length;
    final todayTotal = todayTasks.length;
    final double todayProgress = todayTotal == 0 ? 1.0 : (todayCompleted / todayTotal);

    // Overdue tasks
    final overdueTasks = allTasks.where((t) {
      if (t.dueDate == null || t.isCompleted) return false;
      final target = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      final today = DateTime(now.year, now.month, now.day);
      return target.isBefore(today);
    }).toList();

    // Productivity score (0-100) based on completion ratio
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final totalCount = allTasks.length;
    final productivityScore = totalCount == 0 ? 88 : ((completedCount / totalCount) * 100).toInt().clamp(20, 98);

    return Scaffold(
      appBar: AppBar(
        title: const TaskFlowLogo(size: 28),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(LucideIcons.bell, size: 20),
                if (unreadNotifs > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: AppAvatar(
              name: userName,
              avatarUrl: userAvatarUrl,
              radius: 14,
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskProvider.notifier).loadAll();
          await ref.read(projectProvider.notifier).loadProjects();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Greeting & User Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, $userName 👋',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your productivity overview for today',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's Progress Hero Card
            GlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$todayCompleted of $todayTotal tasks completed',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(todayProgress * 100).toInt()}%',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: todayProgress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 Animated Statistics Cards (Remaining, Overdue, Score)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Remaining',
                    value: '${allTasks.where((t) => !t.isCompleted).length}',
                    icon: LucideIcons.clock,
                    color: AppColors.inProgress,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Overdue',
                    value: '${overdueTasks.length}',
                    icon: LucideIcons.alertCircle,
                    color: overdueTasks.isNotEmpty ? AppColors.error : AppColors.completed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Score',
                    value: '$productivityScore',
                    icon: LucideIcons.zap,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Productivity Chart
            GlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Productivity',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text('Completed vs Created', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/analytics'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      days[value.toInt()],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodySmall?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 4, 3, theme.colorScheme.primary),
                          _buildBarGroup(1, 6, 5, theme.colorScheme.primary),
                          _buildBarGroup(2, 5, 5, theme.colorScheme.primary),
                          _buildBarGroup(3, 7, 6, theme.colorScheme.primary),
                          _buildBarGroup(4, 8, 7, theme.colorScheme.primary),
                          _buildBarGroup(5, 3, 2, theme.colorScheme.primary),
                          _buildBarGroup(6, 4, 4, theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today's Schedule Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.push('/today'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (todayTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.smile, size: 36, color: theme.colorScheme.primary),
                      const SizedBox(height: 10),
                      Text('No tasks scheduled for today!', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Add a new task or enjoy your free time.', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else
              ...todayTasks.take(4).map(
                    (task) => TaskCard(
                      task: task,
                      onToggleComplete: (val) {
                        ref.read(taskProvider.notifier).toggleComplete(task.id, val);
                      },
                      onTap: () {
                        ref.read(taskProvider.notifier).selectTask(task);
                        context.push('/task-details', extra: task);
                      },
                      onDelete: () => ref.read(taskProvider.notifier).moveToTrash(task.id),
                      onArchive: () => ref.read(taskProvider.notifier).archiveTask(task.id),
                    ),
                  ),
            const SizedBox(height: 20),

            // Recent Projects Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Projects',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.push('/projects'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...projectState.projects.take(3).map(
                  (project) {
                    final pTasks = allTasks.where((t) => t.projectId == project.id).toList();
                    final pCompleted = pTasks.where((t) => t.isCompleted).length;
                    return ProjectCard(
                      project: project,
                      totalTasks: pTasks.length,
                      completedTasks: pCompleted,
                      onTap: () {
                        ref.read(projectProvider.notifier).selectProject(project);
                        context.push('/project-details', extra: project);
                      },
                    );
                  },
                ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y1, double y2, Color primary) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: primary,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: y2,
          color: primary.withOpacity(0.35),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
