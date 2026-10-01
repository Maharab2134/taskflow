import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/team_provider.dart';
import 'invite_member_dialog.dart';

class TeamMembersScreen extends ConsumerWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final members = ref.watch(teamProvider);
    final profile = ref.watch(profileProvider).asData?.value;
    final authState = ref.watch(authProvider);
    final myEmail = profile?.email ?? authState.profile?.email ?? '';
    final myName = profile?.fullName ?? authState.profile?.fullName ?? 'You';
    final myAvatar = profile?.avatarUrl ?? authState.profile?.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus, size: 20),
            tooltip: 'Add Member',
            onPressed: () => showInviteMemberDialog(context: context, ref: ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // ─── Section: You (Admin) ───────────────────────────────────
          _SectionHeader(label: 'Workspace Admin'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    AppAvatar(
                      name: myName,
                      avatarUrl: myAvatar,
                      radius: 22,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.inProgress,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(LucideIcons.shieldCheck, size: 9, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              myName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.inProgress.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('You',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inProgress)),
                          ),
                        ],
                      ),
                      if (myEmail.isNotEmpty)
                        Text(
                          myEmail,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inProgress.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Admin',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inProgress)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─── Section: Team Members ──────────────────────────────────
          _SectionHeader(label: 'Team Members (${members.length})'),
          const SizedBox(height: 8),

          if (members.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.users, size: 36, color: theme.colorScheme.outline),
                  const SizedBox(height: 10),
                  Text('No members added yet', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Add team members to assign tasks\nand track their progress.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => showInviteMemberDialog(context: context, ref: ref),
                    icon: const Icon(LucideIcons.userPlus, size: 14),
                    label: const Text('Add First Member'),
                  ),
                ],
              ),
            )
          else
            ...members.map((m) {
              final isMe = myEmail.isNotEmpty && m.email.trim().toLowerCase() == myEmail.toLowerCase();
              if (isMe) return const SizedBox.shrink(); // Already shown above

              final isOwner = m.role.toLowerCase().contains('owner') ||
                  m.role.toLowerCase().contains('admin') ||
                  m.role.toLowerCase().contains('lead');

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AppAvatar(name: m.name, avatarUrl: m.avatarUrl, radius: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              m.email,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.inProgress.withOpacity(0.12)
                              : theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOwner ? AppColors.inProgress : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(LucideIcons.userMinus, size: 16, color: AppColors.error),
                        tooltip: 'Remove from team',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove Member?'),
                              content: Text(
                                  'Remove ${m.name} from the workspace? They will no longer be assignable to tasks.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(teamProvider.notifier).removeMember(m.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showInviteMemberDialog(context: context, ref: ref),
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text('Add Member'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: theme.colorScheme.outline.withOpacity(0.3))),
      ],
    );
  }
}
