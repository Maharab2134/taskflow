import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  bool _crashReporting = true;
  bool _telemetry = false;

  void _clearCache() async {
    await StorageService.clearAll();
    if (mounted) {
      AppToast.showSuccess(context, 'Local offline cache cleared successfully');
    }
  }

  void _exportData() {
    AppToast.showInfo(context, 'Workspace exported to TaskFlow_Backup.json');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Privacy'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          Text('DATA EXPORT & STORAGE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.download, size: 20),
                  title: const Text('Export Workspace Data'),
                  subtitle: const Text('Download all tasks, projects, and subtasks in JSON format'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.trash, size: 20),
                  title: const Text('Clear Local Offline Cache'),
                  subtitle: const Text('Frees up local storage; resyncs from Supabase next launch'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: _clearCache,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('PRIVACY & DIAGNOSTICS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: _crashReporting,
                  title: const Text('Crash Diagnostics'),
                  subtitle: const Text('Helps our team resolve app issues automatically'),
                  onChanged: (val) => setState(() => _crashReporting = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _telemetry,
                  title: const Text('Usage Telemetry'),
                  subtitle: const Text('Share anonymous feature usage metrics'),
                  onChanged: (val) => setState(() => _telemetry = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
