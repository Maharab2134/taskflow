import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/task_model.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../tasks/create_task_sheet.dart';
import '../team/invite_member_dialog.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProjectMembersSheet(BuildContext context) {
    final theme = Theme.of(context);
    final members = ref.watch(teamProvider);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Collaborators',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${widget.project.name} • ${members.length} members',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showInviteMemberDialog(
                        context: context,
                        ref: ref,
                        defaultProjectName: widget.project.name,
                      );
                    },
                    icon: const Icon(LucideIcons.userPlus, size: 14),
                    label: const Text('Invite'),
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, idx) {
                    final m = members[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            AppAvatar(name: m.name, avatarUrl: m.avatarUrl, radius: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  Text(m.email, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                m.role,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTasks = ref.watch(taskProvider).allTasks;
    final projectTasks = allTasks.where((t) => t.projectId == widget.project.id).toList();

    Color pColor = theme.colorScheme.primary;
    if (widget.project.color.startsWith('#')) {
      final hex = widget.project.color.replaceAll('#', '');
      pColor = Color(int.parse('FF$hex', radix: 16));
    }

    final completedCount = projectTasks.where((t) => t.isCompleted).length;
    final totalCount = projectTasks.length;
    final double progressRatio = totalCount == 0 ? 0.0 : (completedCount / totalCount);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.users, size: 18),
            tooltip: 'Project Members',
            onPressed: () => _showProjectMembersSheet(context),
          ),
          IconButton(
            icon: const Icon(LucideIcons.edit2, size: 18),
            tooltip: 'Edit Project',
            onPressed: () => context.push('/edit-project', extra: widget.project),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
            tooltip: 'Delete Project',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Project?'),
                  content: Text('Are you sure you want to delete "${widget.project.name}"? Tasks associated with this project will be kept in your task list.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete Project'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref.read(projectProvider.notifier).deleteProject(widget.project.id);
                if (mounted) {
                  AppToast.showInfo(context, 'Project "${widget.project.name}" deleted');
                  context.pop();
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.list, size: 16), text: 'List'),
            Tab(icon: Icon(LucideIcons.kanban, size: 16), text: 'Kanban Board'),
            Tab(icon: Icon(LucideIcons.calendar, size: 16), text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. LIST VIEW
          ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              // Project Progress Card
              GlassCard(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$completedCount of $totalCount Tasks Completed', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text('${(progressRatio * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w800, color: pColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(pColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (projectTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.checkSquare, size: 40, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(height: 12),
                        Text('No tasks in this project yet', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                )
              else
                ...projectTasks.map(
                  (task) => TaskCard(
                    task: task,
                    onToggleComplete: (val) => ref.read(taskProvider.notifier).toggleComplete(task.id, val),
                    onTap: () {
                      ref.read(taskProvider.notifier).selectTask(task);
                      context.push('/task-details', extra: task);
                    },
                    onDelete: () => ref.read(taskProvider.notifier).moveToTrash(task.id),
                    onArchive: () => ref.read(taskProvider.notifier).archiveTask(task.id),
                  ),
                ),
            ],
          ),

          // 2. KANBAN BOARD VIEW (DRAG AND DROP SUPPORT)
          _KanbanBoardView(
            projectId: widget.project.id,
            projectTasks: projectTasks,
          ),

          // 3. CALENDAR / TIMELINE VIEW
          ListView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              Text(
                'Project Timeline & Deadlines',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...projectTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      ref.read(taskProvider.notifier).selectTask(task);
                      context.push('/task-details', extra: task);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                task.dueDate != null ? DateFormatter.formatDayOfWeek(task.dueDate!) : 'TBD',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pColor),
                              ),
                              Text(
                                task.dueDate != null ? '${task.dueDate!.day}' : '-',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: pColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              Text(task.status.replaceAll('_', ' ').toUpperCase(), style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        PriorityBadge(priority: task.priority),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => CreateTaskSheet(initialProjectId: widget.project.id),
          );
        },
        backgroundColor: pColor,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus, size: 20),
      ),
    );
  }
}

class _KanbanBoardView extends ConsumerStatefulWidget {
  final String projectId;
  final List<TaskModel> projectTasks;

  const _KanbanBoardView({
    required this.projectId,
    required this.projectTasks,
  });

  @override
  ConsumerState<_KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends ConsumerState<_KanbanBoardView> {
  late PageController _pageController;
  int _activeColumnIndex = 0;

  static const _columns = [
    {
      'status': 'todo',
      'title': 'To Do',
      'icon': LucideIcons.circleDot,
      'color': AppColors.todo,
    },
    {
      'status': 'in_progress',
      'title': 'In Progress',
      'icon': LucideIcons.timer,
      'color': AppColors.inProgress,
    },
    {
      'status': 'review',
      'title': 'In Review',
      'icon': LucideIcons.eye,
      'color': AppColors.inReview,
    },
    {
      'status': 'completed',
      'title': 'Done',
      'icon': LucideIcons.checkCircle2,
      'color': AppColors.completed,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToColumn(int index) {
    setState(() => _activeColumnIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openAddTask(String statusKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskSheet(
        initialProjectId: widget.projectId,
        initialStatus: statusKey,
      ),
    );
  }

  Widget _buildColumnSelector(ThemeData theme) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _columns.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final col = _columns[index];
          final statusKey = col['status'] as String;
          final title = col['title'] as String;
          final color = col['color'] as Color;
          final icon = col['icon'] as IconData;
          final count = widget.projectTasks.where((t) => t.status == statusKey).length;
          final isSelected = _activeColumnIndex == index;

          return InkWell(
            onTap: () => _scrollToColumn(index),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.16) : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.4),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: isSelected ? color : theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn({
    required BuildContext context,
    required Map<String, Object> col,
    required List<TaskModel> tasksInColumn,
    required ThemeData theme,
    required bool isDark,
    double? width,
  }) {
    final statusKey = col['status'] as String;
    final title = col['title'] as String;
    final color = col['color'] as Color;
    final icon = col['icon'] as IconData;

    return DragTarget<TaskModel>(
      onWillAccept: (data) => true,
      onAccept: (droppedTask) {
        ref.read(taskProvider.notifier).updateStatus(droppedTask.id, statusKey);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: width,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? color.withOpacity(0.08)
                : (isDark ? AppColors.darkCard : AppColors.lightCardElevated),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isHovered ? color : theme.colorScheme.outline.withOpacity(0.6),
              width: isHovered ? 2 : 1,
            ),
            boxShadow: isHovered
                ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Column Header with Accent Border
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      title.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasksInColumn.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.plus, size: 16),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Add to $title',
                      onPressed: () => _openAddTask(statusKey),
                    ),
                  ],
                ),
              ),

              // Column Task List
              Expanded(
                child: tasksInColumn.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color.withOpacity(0.6), size: 20),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No tasks in $title',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isHovered ? 'Drop task to move here' : 'Drag tasks or tap + to add',
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _openAddTask(statusKey),
                                icon: const Icon(LucideIcons.plus, size: 14),
                                label: const Text('Add Task', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: tasksInColumn.length,
                        itemBuilder: (context, idx) {
                          final task = tasksInColumn[idx];
                          return Draggable<TaskModel>(
                            data: task,
                            feedback: Material(
                              elevation: 10,
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              child: Transform.rotate(
                                angle: 0.04,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.78,
                                  child: _KanbanCard(
                                    task: task,
                                    isDragging: true,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _KanbanCard(task: task),
                            ),
                            child: _KanbanCard(task: task),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      children: [
        // Top interactive Column Tabs on Mobile
        if (isMobile) _buildColumnSelector(theme),

        Expanded(
          child: isMobile
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: _columns.length,
                  onPageChanged: (index) {
                    setState(() => _activeColumnIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final col = _columns[index];
                    final statusKey = col['status'] as String;
                    final tasksInColumn =
                        widget.projectTasks.where((t) => t.status == statusKey).toList();

                    return _buildColumn(
                      context: context,
                      col: col,
                      tasksInColumn: tasksInColumn,
                      theme: theme,
                      isDark: isDark,
                    );
                  },
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  itemCount: _columns.length,
                  itemBuilder: (context, index) {
                    final col = _columns[index];
                    final statusKey = col['status'] as String;
                    final tasksInColumn =
                        widget.projectTasks.where((t) => t.status == statusKey).toList();

                    return _buildColumn(
                      context: context,
                      col: col,
                      tasksInColumn: tasksInColumn,
                      theme: theme,
                      isDark: isDark,
                      width: 310,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _KanbanCard extends ConsumerWidget {
  final TaskModel task;
  final bool isDragging;

  const _KanbanCard({
    required this.task,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check overdue
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        !task.isCompleted &&
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
            .isBefore(DateTime(now.year, now.month, now.day));

    // Priority color indicator
    Color priorityColor;
    switch (task.priority) {
      case 'urgent':
        priorityColor = AppColors.priorityUrgent;
        break;
      case 'high':
        priorityColor = AppColors.priorityHigh;
        break;
      case 'medium':
        priorityColor = AppColors.priorityMedium;
        break;
      default:
        priorityColor = AppColors.priorityLow;
    }

    final totalSubtasks = task.subtasks.length;
    final completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        elevation: isDragging ? 8 : 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(taskProvider.notifier).selectTask(task);
            context.push('/task-details', extra: task);
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Priority Badge + Quick Move Action Menu
                Row(
                  children: [
                    PriorityBadge(priority: task.priority),
                    const Spacer(),
                    // Quick status mover popup
                    PopupMenuButton<String>(
                      icon: Icon(
                        LucideIcons.moreVertical,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 140),
                      onSelected: (newStatus) {
                        if (newStatus == 'delete') {
                          ref.read(taskProvider.notifier).moveToTrash(task.id);
                        } else {
                          ref.read(taskProvider.notifier).updateStatus(task.id, newStatus);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          enabled: false,
                          height: 24,
                          child: Text(
                            'MOVE TO',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (task.status != 'todo')
                          const PopupMenuItem(
                            value: 'todo',
                            child: Row(
                              children: [
                                Icon(LucideIcons.circleDot, size: 14, color: AppColors.todo),
                                SizedBox(width: 8),
                                Text('To Do', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        if (task.status != 'in_progress')
                          const PopupMenuItem(
                            value: 'in_progress',
                            child: Row(
                              children: [
                                Icon(LucideIcons.timer, size: 14, color: AppColors.inProgress),
                                SizedBox(width: 8),
                                Text('In Progress', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        if (task.status != 'review')
                          const PopupMenuItem(
                            value: 'review',
                            child: Row(
                              children: [
                                Icon(LucideIcons.eye, size: 14, color: AppColors.inReview),
                                SizedBox(width: 8),
                                Text('In Review', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        if (task.status != 'completed')
                          const PopupMenuItem(
                            value: 'completed',
                            child: Row(
                              children: [
                                Icon(LucideIcons.checkCircle2, size: 14, color: AppColors.completed),
                                SizedBox(width: 8),
                                Text('Done', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Move to Trash', style: TextStyle(fontSize: 13, color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Task Title
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // Bottom Row: Subtasks + Due Date + Assignees
                Row(
                  children: [
                    // Subtasks counter (if present)
                    if (totalSubtasks > 0) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.checkSquare,
                            size: 13,
                            color: completedSubtasks == totalSubtasks
                                ? AppColors.completed
                                : theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$completedSubtasks/$totalSubtasks',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: completedSubtasks == totalSubtasks
                                  ? AppColors.completed
                                  : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Due Date
                    if (task.dueDate != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue ? LucideIcons.alertCircle : LucideIcons.calendar,
                            size: 13,
                            color: isOverdue ? AppColors.error : theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatShortDate(task.dueDate),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                              color: isOverdue ? AppColors.error : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Multi-Assignee Avatars Pile
                    if (task.assigneeAvatars.isNotEmpty)
                      _buildAssigneesPile(task.assigneeAvatars),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusMedium),
                  bottomLeft: Radius.circular(AppConstants.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildAssigneesPile(List<String> avatars) {
    const double avatarRadius = 10;
    const double overlap = 14;
    final displayAvatars = avatars.take(3).toList();
    final remaining = avatars.length - displayAvatars.length;

    return SizedBox(
      height: 22,
      width: (displayAvatars.length * overlap) + (remaining > 0 ? overlap : 8),
      child: Stack(
        children: [
          ...displayAvatars.asMap().entries.map((entry) {
            final idx = entry.key;
            final url = entry.value;
            return Positioned(
              left: idx * overlap,
              child: AppAvatar(
                name: 'Member',
                avatarUrl: url,
                radius: avatarRadius,
                showBorder: true,
                borderColor: Colors.white,
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: displayAvatars.length * overlap,
              child: Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
