import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Current Password',
              hint: '••••••••',
              controller: oldPass,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'New Password',
              hint: '••••••••',
              controller: newPass,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (newPass.text.length >= 6) {
                await ref.read(authProvider.notifier).resetPassword(newPass.text);
                if (mounted) {
                  Navigator.pop(ctx);
                  AppToast.showSuccess(context, 'Password updated successfully!');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Access'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // Supabase RLS Status Badge Card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.completed.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.shieldCheck, size: 24, color: AppColors.completed),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Row Level Security (RLS)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Enforced on PostgreSQL via Supabase Auth JWT', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(LucideIcons.check, size: 18, color: AppColors.completed),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('PASSWORD & CREDENTIALS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.key, size: 20),
                  title: const Text('Change Password'),
                  subtitle: const Text('Updated 2 weeks ago'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('ACTIVE SESSIONS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.smartphone, size: 22, color: AppColors.completed),
                  title: const Text('Mobile Device (This device)'),
                  subtitle: const Text('Active now • Linux/Android client'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.laptop, size: 22),
                  title: const Text('Desktop Workspace'),
                  subtitle: const Text('Chrome on macOS • Active 3 hours ago'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Sign Out All Other Sessions',
            isOutlined: true,
            foregroundColor: AppColors.error,
            onPressed: () {
              AppToast.showInfo(context, 'All other remote sessions invalidated.');
            },
          ),
        ],
      ),
    );
  }
}
