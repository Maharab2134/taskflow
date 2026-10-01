import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../providers/team_provider.dart';

Future<void> showInviteMemberDialog({
  required BuildContext context,
  required WidgetRef ref,
  String? defaultProjectName,
}) async {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  String selectedRole = 'Member';
  final formKey = GlobalKey<FormState>();

  final theme = Theme.of(context);

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              keyboardPadding > 0 ? keyboardPadding + 16 : 28,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.userPlus, color: theme.colorScheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invite Team Member',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                defaultProjectName != null
                                    ? 'Add collaborator to $defaultProjectName'
                                    : 'Add teammate to your workspace',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Full Name *',
                      hint: 'e.g. Maya Lin',
                      controller: nameCtrl,
                      prefixIcon: LucideIcons.user,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter full name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email Address *',
                      hint: 'colleague@company.com',
                      controller: emailCtrl,
                      prefixIcon: LucideIcons.mail,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter email address';
                        if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Workspace Role',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Admin', 'Lead', 'Member', 'Viewer'].map((role) {
                        final isSel = selectedRole == role;
                        return ChoiceChip(
                          label: Text(role),
                          selected: isSel,
                          onSelected: (_) => setState(() => selectedRole = role),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Send Invitation & Add',
                      icon: LucideIcons.send,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final name = nameCtrl.text.trim();
                          final email = emailCtrl.text.trim();

                          await ref.read(teamProvider.notifier).addMember(
                                name: name,
                                email: email,
                                role: selectedRole,
                              );

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            AppToast.showSuccess(context, '$name added to your team!');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
