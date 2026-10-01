import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../providers/filter_provider.dart';
import '../../providers/project_provider.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(filterProvider);
    final projects = ref.watch(projectProvider).projects;
    final mediaQuery = MediaQuery.of(context);
    final bottomSafe = math.max(mediaQuery.viewPadding.bottom, mediaQuery.padding.bottom);
    final double bottomPadding = bottomSafe > 0 ? bottomSafe + 16 : 28.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing24,
        AppConstants.spacing20,
        AppConstants.spacing24,
        bottomPadding,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXLarge)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters & Sorting',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(filterProvider.notifier).reset();
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Filter
              Text('Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['all', 'todo', 'in_progress', 'review', 'completed'].map((st) {
                  final isSelected = filter.status == st;
                  return ChoiceChip(
                    label: Text(st == 'all' ? 'All Statuses' : st.replaceAll('_', ' ').toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) => ref.read(filterProvider.notifier).setStatus(st),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority Filter
              Text('Priority', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['all', 'low', 'medium', 'high', 'urgent'].map((pr) {
                  final isSelected = filter.priority == pr;
                  return ChoiceChip(
                    label: Text(pr == 'all' ? 'All Priorities' : pr.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) => ref.read(filterProvider.notifier).setPriority(pr),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Project Filter
              Text('Project', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Projects'),
                    selected: filter.projectId == null,
                    onSelected: (_) => ref.read(filterProvider.notifier).setProject(null),
                  ),
                  ...projects.map((p) {
                    final isSelected = filter.projectId == p.id;
                    return ChoiceChip(
                      label: Text(p.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(filterProvider.notifier).setProject(p.id),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Sort By
              Text('Sort By', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Due Date'),
                    selected: filter.sortBy == 'due_date',
                    onSelected: (_) => ref.read(filterProvider.notifier).setSortBy('due_date'),
                  ),
                  ChoiceChip(
                    label: const Text('Priority'),
                    selected: filter.sortBy == 'priority',
                    onSelected: (_) => ref.read(filterProvider.notifier).setSortBy('priority'),
                  ),
                  ChoiceChip(
                    label: const Text('Newest'),
                    selected: filter.sortBy == 'newest',
                    onSelected: (_) => ref.read(filterProvider.notifier).setSortBy('newest'),
                  ),
                  ChoiceChip(
                    label: const Text('Oldest'),
                    selected: filter.sortBy == 'oldest',
                    onSelected: (_) => ref.read(filterProvider.notifier).setSortBy('oldest'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Apply Filters',
                  onPressed: () => context.pop(),
                  icon: LucideIcons.check,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
