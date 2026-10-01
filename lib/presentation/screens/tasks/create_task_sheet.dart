import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/natural_language_parser.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/team_provider.dart';
import '../team/invite_member_dialog.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialStatus;

  const CreateTaskSheet({
    super.key,
    this.initialProjectId,
    this.initialStatus,
  });

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _smartInputController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskInputController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String _priority = 'medium';
  String _status = 'todo';
  String? _projectId;
  final List<String> _subtasks = [];
  final List<String> _selectedAssigneeIds = [];
  final List<String> _selectedAssigneeNames = [];
  final List<String> _selectedAssigneeAvatars = [];

  ParsedTaskResult? _parsedResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _projectId = widget.initialProjectId;
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
    }
    _smartInputController.addListener(_onSmartInputChanged);
  }

  void _onSmartInputChanged() {
    final text = _smartInputController.text;
    if (text.trim().isNotEmpty) {
      final parsed = NaturalLanguageParser.parse(text);
      setState(() {
        _parsedResult = parsed;
        _titleController.text = parsed.title;
        if (parsed.dueDate != null) _dueDate = parsed.dueDate;
        if (parsed.dueTime != null) _dueTime = parsed.dueTime;
        _priority = parsed.priority;
      });
    } else {
      setState(() => _parsedResult = null);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _smartInputController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(text);
        _subtaskInputController.clear();
      });
    }
  }

  void _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppToast.showWarning(context, 'Please enter a task title');
      return;
    }

    final projects = ref.read(projectProvider).projects;
    final selectedProj = projects.where((p) => p.id == _projectId).firstOrNull;

    final taskId = const Uuid().v4();
    final subtaskModels = _subtasks.asMap().entries.map((e) {
      return SubtaskModel(
        id: const Uuid().v4(),
        taskId: taskId,
        title: e.value,
        position: e.key,
      );
    }).toList();

    final newTask = TaskModel(
      id: taskId,
      userId: SupabaseService.instance.currentUser?.id ?? '',
      title: title,
      description: _descController.text.trim(),
      projectId: _projectId,
      projectName: selectedProj?.name,
      projectColor: selectedProj?.color,
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
      dueTime: _dueTime,
      assigneeIds: _selectedAssigneeIds,
      assigneeNames: _selectedAssigneeNames,
      assigneeAvatars: _selectedAssigneeAvatars,
      subtasks: subtaskModels,
    );

    await ref.read(taskProvider.notifier).createTask(newTask);

    if (mounted) {
      context.pop();
      AppToast.showSuccess(context, 'Task "${newTask.title}" created');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final projects = ref.watch(projectProvider).projects;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomSafe = math.max(mediaQuery.viewPadding.bottom, mediaQuery.padding.bottom);
    final double buttonBottomSpacing = bottomSafe > 0 ? bottomSafe + 16 : 28.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: mediaQuery.size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXLarge)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              // Subtle Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Task',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(LucideIcons.sparkles, size: 16), text: 'Smart Quick Add'),
                    Tab(icon: Icon(LucideIcons.listPlus, size: 16), text: 'All Fields'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                // 1. SMART QUICK ADD TAB
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Type naturally with smart dates and priorities:',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _smartInputController,
                        autofocus: true,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Finish portfolio website tomorrow at 8 PM !urgent #dev',
                          filled: true,
                          fillColor: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                        ),
                      ),
                      if (_parsedResult != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.checkCheck, size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Parsed Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (_parsedResult!.title.isNotEmpty)
                                    Chip(
                                      avatar: const Icon(LucideIcons.type, size: 14),
                                      label: Text('Title: ${_parsedResult!.title}'),
                                    ),
                                  if (_dueDate != null)
                                    Chip(
                                      avatar: const Icon(LucideIcons.calendar, size: 14),
                                      label: Text('Due: ${DateFormatter.formatShortDate(_dueDate)}'),
                                    ),
                                  if (_dueTime != null)
                                    Chip(
                                      avatar: const Icon(LucideIcons.clock, size: 14),
                                      label: Text('Time: ${_dueTime!.format(context)}'),
                                    ),
                                  Chip(
                                    avatar: const Icon(LucideIcons.flag, size: 14),
                                    label: Text('Priority: ${_priority.toUpperCase()}'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Project Selector
                      Text('Assign to Project', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: _projectId,
                        decoration: const InputDecoration(hintText: 'None (Standalone Task)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('No Project')),
                          ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (val) => setState(() => _projectId = val),
                      ),
                      const SizedBox(height: 20),
                      _buildAssigneeSelector(theme),
                    ],
                  ),
                ),

                // 2. ALL FIELDS TAB
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Task Title *',
                        hint: 'What needs to be done?',
                        controller: _titleController,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Description (Optional)',
                        hint: 'Add context, links, or notes...',
                        controller: _descController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(LucideIcons.calendar, size: 16),
                              label: Text(_dueDate == null ? 'Due Date' : DateFormatter.formatShortDate(_dueDate)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(LucideIcons.clock, size: 16),
                              label: Text(_dueTime == null ? 'Due Time' : _dueTime!.format(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Priority', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['low', 'medium', 'high', 'urgent'].map((p) {
                          return ChoiceChip(
                            label: Text(p.toUpperCase()),
                            selected: _priority == p,
                            onSelected: (_) => setState(() => _priority = p),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['todo', 'in_progress', 'review'].map((s) {
                          return ChoiceChip(
                            label: Text(s.replaceAll('_', ' ').toUpperCase()),
                            selected: _status == s,
                            onSelected: (_) => setState(() => _status = s),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildAssigneeSelector(theme),
                      const SizedBox(height: 16),
                      // Subtasks Checklist Section
                      Text('Subtasks Checklist', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskInputController,
                              decoration: const InputDecoration(
                                hintText: 'Add a subtask step...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addSubtask,
                            icon: const Icon(LucideIcons.plus, size: 16),
                          ),
                        ],
                      ),
                      if (_subtasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ..._subtasks.asMap().entries.map(
                              (entry) => ListTile(
                                dense: true,
                                leading: const Icon(LucideIcons.circle, size: 12),
                                title: Text(entry.value),
                                trailing: IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 14),
                                  onPressed: () => setState(() => _subtasks.removeAt(entry.key)),
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
                    ],
                  ),
                ),
              ),
              // Bottom Create Task Button with safe padding
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  buttonBottomSpacing,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Create Task',
                    onPressed: _submit,
                    icon: LucideIcons.plus,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssigneeSelector(ThemeData theme) {
    final teamMembers = ref.watch(teamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Assignees', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (_selectedAssigneeIds.isNotEmpty)
              Text(
                '${_selectedAssigneeIds.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...teamMembers.map((member) {
              final isSelected = _selectedAssigneeIds.contains(member.id);
              return FilterChip(
                avatar: AppAvatar(
                  name: member.name,
                  avatarUrl: member.avatarUrl,
                  radius: 12,
                ),
                label: Text(member.name),
                selected: isSelected,
                showCheckmark: true,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAssigneeIds.add(member.id);
                      _selectedAssigneeNames.add(member.name);
                      _selectedAssigneeAvatars.add(member.avatarUrl);
                    } else {
                      _selectedAssigneeIds.remove(member.id);
                      _selectedAssigneeNames.remove(member.name);
                      _selectedAssigneeAvatars.remove(member.avatarUrl);
                    }
                  });
                },
              );
            }),
            ActionChip(
              avatar: const Icon(LucideIcons.userPlus, size: 14),
              label: const Text('Invite New'),
              onPressed: () => showInviteMemberDialog(context: context, ref: ref),
            ),
          ],
        ),
      ],
    );
  }
}
