import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _taskReminders = true;
  bool _dueDateAlerts = true;
  bool _commentsAndReplies = true;
  bool _teamMentions = true;
  bool _projectUpdates = false;
  bool _dailyBriefing = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          Text('ALERTS & REMINDERS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: _taskReminders,
                  title: const Text('Task Reminders'),
                  subtitle: const Text('Notify when a scheduled task alarm fires'),
                  secondary: const Icon(LucideIcons.bellRing, size: 20),
                  onChanged: (val) => setState(() => _taskReminders = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _dueDateAlerts,
                  title: const Text('Due Date Alerts'),
                  subtitle: const Text('Notify 1 hour before deadlines'),
                  secondary: const Icon(LucideIcons.clock, size: 20),
                  onChanged: (val) => setState(() => _dueDateAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _dailyBriefing,
                  title: const Text('Daily Morning Briefing'),
                  subtitle: const Text('Digest of today\'s agenda at 8:00 AM'),
                  secondary: const Icon(LucideIcons.sun, size: 20),
                  onChanged: (val) => setState(() => _dailyBriefing = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('TEAM & COLLABORATION', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: _teamMentions,
                  title: const Text('Mentions (@you)'),
                  subtitle: const Text('When someone tags you in a comment or task'),
                  secondary: const Icon(LucideIcons.atSign, size: 20),
                  onChanged: (val) => setState(() => _teamMentions = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _commentsAndReplies,
                  title: const Text('Comments & Discussions'),
                  subtitle: const Text('Replies to tasks you are assigned to'),
                  secondary: const Icon(LucideIcons.messageSquare, size: 20),
                  onChanged: (val) => setState(() => _commentsAndReplies = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _projectUpdates,
                  title: const Text('Project Milestones'),
                  subtitle: const Text('Project status and completion updates'),
                  secondary: const Icon(LucideIcons.folderSync, size: 20),
                  onChanged: (val) => setState(() => _projectUpdates = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
