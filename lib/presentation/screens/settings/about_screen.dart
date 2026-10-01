import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/taskflow_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About TaskFlow'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        children: [
          const Center(child: TaskFlowLogo(size: 60)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'TaskFlow',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              'Version ${AppConstants.appVersion} (Build 100)',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 28),

          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About the Application',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'TaskFlow is a production-grade task and project management suite engineered for individual high-performers and modern product teams. Inspired by the speed of Linear, the flexibility of Notion, and the simplicity of Todoist.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Core Technology Stack',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const _TechItem(label: 'Framework', val: 'Flutter 3.x & Dart'),
                const _TechItem(label: 'Backend & DB', val: 'Supabase Free Tier (PostgreSQL + RLS)'),
                const _TechItem(label: 'State Management', val: 'Riverpod 2.x'),
                const _TechItem(label: 'Routing', val: 'GoRouter'),
                const _TechItem(label: 'Design System', val: 'Material 3 & Lucide Icons'),
                const _TechItem(label: 'Charts & Analytics', val: 'fl_chart'),
                const _TechItem(label: 'Local Storage', val: 'SharedPreferences'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: TextButton.icon(
              onPressed: () => showLicensePage(context: context),
              icon: const Icon(LucideIcons.fileCode, size: 16),
              label: const Text('Open Source Licenses'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String label;
  final String val;

  const _TechItem({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
