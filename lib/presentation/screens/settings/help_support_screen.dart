import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          // Quick Support Action
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.lifeBuoy, size: 24, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Have a Question?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Our developer and product team is here to assist.', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('FREQUENTLY ASKED QUESTIONS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                ExpansionTile(
                  title: Text('How does smart natural language task parsing work?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'When typing in Quick Add, write phrases like "Deploy server tomorrow at 5 PM !urgent #dev". TaskFlow automatically extracts the title, due date, time, and priority tags.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  title: Text('Does TaskFlow work offline?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Yes! All tasks, projects, and subtasks are cached locally. When internet connectivity is restored, all modifications synchronize seamlessly with Supabase.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  title: Text('How do I connect my own Supabase project?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Copy .env.example to .env and input your SUPABASE_URL and SUPABASE_ANON_KEY. Run the SQL schema script provided in supabase/schema.sql to provision tables and RLS policies.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  title: Text('What keyboard shortcuts are supported?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Press Ctrl + K (or ⌘ + K on macOS) from anywhere in the application to trigger the Command Palette global search.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feedback form
          Text('SEND US FEEDBACK', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const AppTextField(
                  hint: 'Tell us how we can make TaskFlow better...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Submit Feedback',
                    onPressed: () {
                      AppToast.showSuccess(context, 'Thank you! Feedback received.');
                    },
                    icon: LucideIcons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
