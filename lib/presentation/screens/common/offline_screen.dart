import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/offline_indicator.dart';
import '../../providers/sync_provider.dart';

class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sync = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode & Sync'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: sync.status == SyncStatus.offline
                    ? AppColors.error.withOpacity(0.12)
                    : AppColors.completed.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sync.status == SyncStatus.offline ? LucideIcons.wifiOff : LucideIcons.wifi,
                size: 38,
                color: sync.status == SyncStatus.offline ? AppColors.error : AppColors.completed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              sync.status == SyncStatus.offline
                  ? 'You are currently Offline'
                  : (sync.status == SyncStatus.syncing ? 'Synchronizing Data...' : 'All Changes Synced'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'TaskFlow preserves all changes in your local SharedPreferences cache. As soon as you reconnect, changes sync seamlessly to PostgreSQL with Row Level Security.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OfflineIndicator(
              status: sync.status,
              onTap: () => ref.read(syncProvider.notifier).toggleOfflineMode(),
            ),
            const SizedBox(height: 32),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Toggle Offline Mode Simulation', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Switch(
                    value: sync.status == SyncStatus.offline,
                    onChanged: (_) => ref.read(syncProvider.notifier).toggleOfflineMode(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: sync.status == SyncStatus.offline ? 'Attempt Reconnect & Sync' : 'Return to Dashboard',
              icon: LucideIcons.refreshCw,
              onPressed: () {
                if (sync.status == SyncStatus.offline) {
                  ref.read(syncProvider.notifier).triggerSync();
                } else {
                  context.go('/dashboard');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
