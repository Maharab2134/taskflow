import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../tasks/create_task_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  List<TaskModel> _getTasksForDate(DateTime date, List<TaskModel> allTasks) {
    return allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTasks = ref.watch(taskProvider).allTasks;
    final selectedDateTasks = _getTasksForDate(_selectedDate, allTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays, size: 20),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
              });
            },
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const CreateTaskSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Month'),
            Tab(text: 'Week'),
            Tab(text: 'Day'),
            Tab(text: 'Agenda'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. MONTH VIEW
          Column(
            children: [
              // Month Switcher Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.formatMonthYear(_currentMonth),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, size: 18),
                          onPressed: _prevMonth,
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight, size: 18),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Day of week labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                    return SizedBox(
                      width: 32,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              // Calendar Days Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildMonthGrid(allTasks),
              ),
              const Divider(height: 20),
              // Tasks for Selected Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks for ${DateFormatter.formatShortDate(_selectedDate)}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text('${selectedDateTasks.length} tasks', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: selectedDateTasks.isEmpty
                    ? Center(
                        child: Text('No tasks on this day', style: theme.textTheme.bodySmall),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedDateTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedDateTasks[index];
                          return TaskCard(
                            task: task,
                            onToggleComplete: (val) => ref.read(taskProvider.notifier).toggleComplete(task.id, val),
                            onTap: () {
                              ref.read(taskProvider.notifier).selectTask(task);
                              context.push('/task-details', extra: task);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),

          // 2. WEEK VIEW
          _buildWeekView(allTasks),

          // 3. DAY VIEW
          _buildDayView(selectedDateTasks),

          // 4. AGENDA VIEW
          _buildAgendaView(allTasks),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(List<TaskModel> allTasks) {
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon

    final List<Widget> dayWidgets = [];

    // Leading empty slots
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 38, height: 38));
    }

    // Days of current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isToday = DateFormatter.isToday(date);
      final tasksForDay = _getTasksForDate(date, allTasks);

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isToday ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : (isToday ? theme.colorScheme.primary : null),
                  ),
                ),
                if (tasksForDay.isNotEmpty)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.inProgress,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 6,
      runSpacing: 6,
      children: dayWidgets,
    );
  }

  Widget _buildWeekView(List<TaskModel> allTasks) {
    final theme = Theme.of(context);
    final now = _selectedDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((d) {
            final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = d),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormatter.formatDayOfWeek(d),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        ..._getTasksForDate(_selectedDate, allTasks).map(
          (t) => TaskCard(
            task: t,
            onToggleComplete: (val) => ref.read(taskProvider.notifier).toggleComplete(t.id, val),
            onTap: () {
              ref.read(taskProvider.notifier).selectTask(t);
              context.push('/task-details', extra: t);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayView(List<TaskModel> tasks) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 14, // 8 AM to 9 PM
      itemBuilder: (context, index) {
        final hour = 8 + index;
        final hourLabel = hour > 12 ? '${hour - 12} PM' : (hour == 12 ? '12 PM' : '$hour AM');

        final matching = tasks.where((t) => t.dueTime != null && t.dueTime!.hour == hour).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 55,
                child: Text(
                  hourLabel,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: matching.isEmpty
                    ? Container(
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5))),
                        ),
                      )
                    : Column(
                        children: matching.map(
                          (t) => GlassCard(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            onTap: () {
                              ref.read(taskProvider.notifier).selectTask(t);
                              context.push('/task-details', extra: t);
                            },
                            child: Row(
                              children: [
                                Text(t.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(t.dueTime!.format(context), style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgendaView(List<TaskModel> allTasks) {
    final sorted = List<TaskModel>.from(allTasks)..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final t = sorted[index];
        return TaskCard(
          task: t,
          onToggleComplete: (val) => ref.read(taskProvider.notifier).toggleComplete(t.id, val),
          onTap: () {
            ref.read(taskProvider.notifier).selectTask(t);
            context.push('/task-details', extra: t);
          },
        );
      },
    );
  }
}
