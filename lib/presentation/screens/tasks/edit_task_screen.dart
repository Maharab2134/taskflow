import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/team_provider.dart';
import '../team/invite_member_dialog.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _priority;
  late String _status;
  late String? _projectId;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late List<String> _selectedAssigneeIds;
  late List<String> _selectedAssigneeNames;
  late List<String> _selectedAssigneeAvatars;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _status = widget.task.status;
    _projectId = widget.task.projectId;
    _dueDate = widget.task.dueDate;
    _dueTime = widget.task.dueTime;
    _selectedAssigneeIds = List<String>.from(widget.task.assigneeIds);
    _selectedAssigneeNames = List<String>.from(widget.task.assigneeNames);
    _selectedAssigneeAvatars = List<String>.from(widget.task.assigneeAvatars);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final projects = ref.read(projectProvider).projects;
    final proj = projects.where((p) => p.id == _projectId).firstOrNull;

    final updated = widget.task.copyWith(
      title: title,
      description: _descController.text.trim(),
      priority: _priority,
      status: _status,
      projectId: _projectId,
      projectName: proj?.name,
      projectColor: proj?.color,
      dueDate: _dueDate,
      dueTime: _dueTime,
      assigneeIds: _selectedAssigneeIds,
      assigneeNames: _selectedAssigneeNames,
      assigneeAvatars: _selectedAssigneeAvatars,
      completedAt: _status == 'completed' ? (widget.task.completedAt ?? DateTime.now()) : null,
    );

    await ref.read(taskProvider.notifier).updateTask(updated);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = ref.watch(projectProvider).projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Task Title',
              hint: 'Task name',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              hint: 'Task description...',
              controller: _descController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    icon: const Icon(LucideIcons.calendar, size: 16),
                    label: Text(_dueDate == null ? 'Due Date' : DateFormatter.formatShortDate(_dueDate)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _dueTime ?? const TimeOfDay(hour: 12, minute: 0),
                      );
                      if (picked != null) setState(() => _dueTime = picked);
                    },
                    icon: const Icon(LucideIcons.clock, size: 16),
                    label: Text(_dueTime == null ? 'Due Time' : _dueTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Project', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _projectId,
              decoration: const InputDecoration(hintText: 'None'),
              items: [
                const DropdownMenuItem(value: null, child: Text('No Project')),
                ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
              ],
              onChanged: (val) => setState(() => _projectId = val),
            ),
            const SizedBox(height: 20),
            Text('Priority', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
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
            const SizedBox(height: 20),
            Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['todo', 'in_progress', 'review', 'completed'].map((s) {
                return ChoiceChip(
                  label: Text(s.replaceAll('_', ' ').toUpperCase()),
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assignees', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (_selectedAssigneeIds.isNotEmpty)
                  Text(
                    '${_selectedAssigneeIds.length} assigned',
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
                ...ref.watch(teamProvider).map((member) {
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
                  label: const Text('+ Invite New'),
                  onPressed: () => showInviteMemberDialog(context: context, ref: ref),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Save Changes',
                onPressed: _save,
                icon: LucideIcons.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
