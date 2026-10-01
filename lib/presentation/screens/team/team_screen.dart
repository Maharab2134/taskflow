import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/team_provider.dart';
import 'invite_member_dialog.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(teamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Collaboration'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus, size: 20),
            tooltip: 'Invite Member',
            onPressed: () => showInviteMemberDialog(context: context, ref: ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // Team Banner
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.users, size: 26, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Engineering Core', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${members.length} members • Active Workspace', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => context.push('/team-members'),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Team Members Preview Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Collaborators (${members.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => showInviteMemberDialog(context: context, ref: ref),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Invite'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...members.take(6).map((m) {
            return _MemberTile(
              name: m.name,
              role: m.role,
              avatarUrl: m.avatarUrl,
              email: m.email,
            );
          }),
          const SizedBox(height: 24),

          // Recent Team Activity
          Text('Recent Team Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const _ActivityTile(
            user: 'Elena Rostova',
            action: 'reviewed task',
            target: 'Design landing page hero section',
            time: '2 hours ago',
          ),
          const _ActivityTile(
            user: 'David Kim',
            action: 'updated project status to Active',
            target: 'Mobile Banking App',
            time: 'Yesterday',
          ),
          const _ActivityTile(
            user: 'Sarah Connor',
            action: 'added 3 subtasks to',
            target: 'Audit security encryption and biometric login',
            time: '2 days ago',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showInviteMemberDialog(context: context, ref: ref),
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text('Invite Member'),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;
  final String email;

  const _MemberTile({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            AppAvatar(
              name: name,
              avatarUrl: avatarUrl,
              radius: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(email, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String user;
  final String action;
  final String target;
  final String time;

  const _ActivityTile({
    required this.user,
    required this.action,
    required this.target,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.activity, size: 14, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(text: '$user ', style: const TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: '$action '),
                        TextSpan(text: target, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(time, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
