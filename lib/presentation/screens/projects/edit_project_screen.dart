import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/project_model.dart';
import '../../providers/project_provider.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const EditProjectScreen({super.key, required this.project});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedColor;
  late String _selectedIcon;
  late String _status;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descController = TextEditingController(text: widget.project.description);
    _selectedColor = widget.project.color;
    _selectedIcon = widget.project.icon;
    _status = widget.project.status;
    _deadline = widget.project.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final updated = widget.project.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
        status: _status,
        deadline: _deadline,
      );
      await ref.read(projectProvider.notifier).updateProject(updated);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Project Name',
                hint: 'Name',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Description',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['active', 'paused', 'completed', 'archived'].map((st) {
                  return ChoiceChip(
                    label: Text(st.toUpperCase()),
                    selected: _status == st,
                    onSelected: (_) => setState(() => _status = st),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Deadline', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
                icon: const Icon(LucideIcons.calendar, size: 16),
                label: Text(_deadline == null ? 'Set Deadline' : DateFormatter.formatShortDate(_deadline)),
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
      ),
    );
  }
}
