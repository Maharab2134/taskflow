import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';

class SearchCommandPalette extends ConsumerStatefulWidget {
  const SearchCommandPalette({super.key});

  @override
  ConsumerState<SearchCommandPalette> createState() => _SearchCommandPaletteState();
}

class _SearchCommandPaletteState extends ConsumerState<SearchCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTasks = ref.watch(taskProvider).allTasks;
    final allProjects = ref.watch(projectProvider).projects;

    final q = _query.trim().toLowerCase();

    final matchedTasks = q.isEmpty
        ? []
        : allTasks.where((t) {
            return t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q) ||
                t.tags.any((tag) => tag.toLowerCase().contains(q));
          }).toList();

    final matchedProjects = q.isEmpty
        ? []
        : allProjects.where((p) {
            return p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
          }).toList();

    final mediaQuery = MediaQuery.of(context);
    final bottomSafe = math.max(mediaQuery.viewPadding.bottom, mediaQuery.padding.bottom);
    final double bottomPadding = bottomSafe > 0 ? bottomSafe + 16 : 24.0;

    return Container(
      height: mediaQuery.size.height * 0.75,
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXLarge)),
      ),
      child: Column(
        children: [
          // Command Palette Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Type to search tasks, projects, tags...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (val) => setState(() => _query = val),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Results List
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.command, size: 36, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(height: 12),
                        Text(
                          'Command Palette',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Search across all tasks, projects, and tags.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (matchedTasks.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'TASKS (${matchedTasks.length})',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...matchedTasks.map(
                          (t) => GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            onTap: () {
                              context.pop();
                              ref.read(taskProvider.notifier).selectTask(t);
                              context.push('/task-details', extra: t);
                            },
                            child: Row(
                              children: [
                                Icon(LucideIcons.checkSquare, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (t.projectName != null)
                                        Text(
                                          t.projectName!,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(LucideIcons.arrowRight, size: 14, color: theme.textTheme.bodySmall?.color),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (matchedProjects.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'PROJECTS (${matchedProjects.length})',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...matchedProjects.map(
                          (p) => GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            onTap: () {
                              context.pop();
                              ref.read(projectProvider.notifier).selectProject(p);
                              context.push('/project-details', extra: p);
                            },
                            child: Row(
                              children: [
                                Icon(LucideIcons.folder, size: 16, color: theme.colorScheme.secondary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text('${p.progress}%', style: theme.textTheme.bodySmall),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.arrowRight, size: 14, color: theme.textTheme.bodySmall?.color),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (matchedTasks.isEmpty && matchedProjects.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(LucideIcons.searchX, size: 36, color: AppColors.archived),
                                const SizedBox(height: 10),
                                Text('No results for "$_query"', style: theme.textTheme.titleMedium),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
