import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../providers/project_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedColor = '#6366F1';
  String _selectedIcon = 'folder';
  DateTime? _startDate;
  DateTime? _deadline;

  static const List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': LucideIcons.folder},
    {'name': 'globe', 'icon': LucideIcons.globe},
    {'name': 'shopping_bag', 'icon': LucideIcons.shoppingBag},
    {'name': 'credit_card', 'icon': LucideIcons.creditCard},
    {'name': 'book_open', 'icon': LucideIcons.bookOpen},
    {'name': 'smile', 'icon': LucideIcons.smile},
    {'name': 'code', 'icon': LucideIcons.code},
    {'name': 'briefcase', 'icon': LucideIcons.briefcase},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(projectProvider.notifier).addProject(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            color: _selectedColor,
            icon: _selectedIcon,
            startDate: _startDate,
            deadline: _deadline,
          );
      if (mounted) {
        context.pop();
        AppToast.showSuccess(context, 'Project created successfully!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
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
                label: 'Project Name *',
                hint: 'e.g. Mobile Banking App',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter project name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Goals, scope, or notes for the team...',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Color Preset Picker
              Text('Accent Color', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: AppColors.themePresets.map((c) {
                  final hex = '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
                  final isSelected = _selectedColor.toUpperCase() == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: isSelected ? const Center(child: Icon(LucideIcons.check, size: 16, color: Colors.white)) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon Selector
              Text('Project Icon', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _iconOptions.map((opt) {
                  final name = opt['name'] as String;
                  final icon = opt['icon'] as IconData;
                  final isSelected = _selectedIcon == name;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = name),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      icon: const Icon(LucideIcons.calendar, size: 16),
                      label: Text(_startDate == null ? 'Start Date' : DateFormatter.formatShortDate(_startDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) setState(() => _deadline = picked);
                      },
                      icon: const Icon(LucideIcons.clock, size: 16),
                      label: Text(_deadline == null ? 'Deadline' : DateFormatter.formatShortDate(_deadline)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Create Project',
                  onPressed: _submit,
                  icon: LucideIcons.plus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
