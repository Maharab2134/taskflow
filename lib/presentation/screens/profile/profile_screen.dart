import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final allTasks = ref.watch(taskProvider).allTasks;
    final allProjects = ref.watch(projectProvider).projects;

    final completedTasksCount = allTasks.where((t) => t.isCompleted).length;
    final activeProjectsCount = allProjects.where((p) => p.status == 'active').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profile: $err')),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            children: [
              // User Avatar & Bio Card
              GlassCard(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Column(
                  children: [
                    AppAvatar(
                      name: profile.fullName,
                      avatarUrl: profile.avatarUrl,
                      radius: 48,
                      onTap: () => context.push('/edit-profile', extra: profile),
                      badge: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                        ),
                        child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.jobTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile.bio,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/edit-profile', extra: profile),
                      icon: const Icon(LucideIcons.userCheck, size: 16),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Stats Grid
              Text('Career & Productivity Highlights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStatCard(
                      label: 'Completed Tasks',
                      value: '$completedTasksCount',
                      icon: LucideIcons.checkSquare,
                      color: AppColors.completed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatCard(
                      label: 'Active Projects',
                      value: '$activeProjectsCount',
                      icon: LucideIcons.folder,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStatCard(
                      label: 'Productivity Score',
                      value: '94/100',
                      icon: LucideIcons.zap,
                      color: AppColors.inProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatCard(
                      label: 'Workspace Role',
                      value: 'Architect',
                      icon: LucideIcons.award,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions List
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(LucideIcons.users, size: 20),
                      title: const Text('Team Members & Collaborators'),
                      subtitle: const Text('Invite and manage workspace teammates'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () => context.push('/team-members'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.settings, size: 20),
                      title: const Text('Preferences & Settings'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () => context.push('/settings'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.helpCircle, size: 20),
                      title: const Text('Help & Documentation'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () => context.push('/help-support'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(LucideIcons.info, size: 20),
                      title: const Text('About TaskFlow'),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () => context.push('/about'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Button
              AppButton(
                label: 'Log Out',
                isOutlined: true,
                foregroundColor: AppColors.error,
                backgroundColor: AppColors.error,
                icon: LucideIcons.logOut,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text('Are you sure you want to log out of TaskFlow on this device?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
