import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // PREFERENCES
          Text('PREFERENCES', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.palette, size: 20),
                  title: const Text('Appearance & Theme'),
                  subtitle: const Text('Dark mode, light mode, accent colors'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/settings/appearance'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.bell, size: 20),
                  title: const Text('Notification Preferences'),
                  subtitle: const Text('Reminders, mentions, deadlines'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/settings/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECURITY & PRIVACY
          Text('SECURITY & PRIVACY', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.shieldCheck, size: 20),
                  title: const Text('Security & Password'),
                  subtitle: const Text('Change password, 2FA, active sessions'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/settings/security'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.database, size: 20),
                  title: const Text('Data & Privacy'),
                  subtitle: const Text('Cache, export workspace, GDPR'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/settings/data-privacy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SYSTEM & SUPPORT
          Text('SYSTEM & SUPPORT', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.helpCircle, size: 20),
                  title: const Text('Help & Support'),
                  subtitle: const Text('FAQs, keyboard shortcuts, contact'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/help-support'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.info, size: 20),
                  title: const Text('About TaskFlow'),
                  subtitle: const Text('Version 1.0.0 • Production Ready'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign out tile
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(LucideIcons.logOut, size: 20, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
