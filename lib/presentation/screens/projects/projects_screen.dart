import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/project_card.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectProvider);
    final allTasks = ref.watch(taskProvider).allTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: ResponsiveLayout.isMobile(context)
            ? null
            : [
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/create-project'),
                  icon: const Icon(LucideIcons.folderPlus, size: 16),
                  label: const Text('New Project'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: projectState.projects.isEmpty
          ? EmptyStateView.projects(
              onAddProject: () => context.push('/create-project'),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(projectProvider.notifier).loadProjects(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                itemCount: projectState.projects.length,
                itemBuilder: (context, index) {
                  final project = projectState.projects[index];
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
            ),
    );
  }
}
