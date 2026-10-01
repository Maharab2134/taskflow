import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).resetPassword(_passwordController.text.trim());
      if (success && mounted) {
        AppToast.showSuccess(context, 'Password updated successfully!');
        context.go('/dashboard');
      } else if (mounted) {
        final err = ref.read(authProvider).errorMessage ?? 'Failed to update password.';
        AppToast.showError(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Set New Password', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a strong password to safeguard your TaskFlow data.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacing20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'New Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: LucideIcons.lock,
                          validator: (val) => val == null || val.length < 6 ? 'At least 6 characters' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Confirm New Password',
                          hint: '••••••••',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          prefixIcon: LucideIcons.lock,
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Update Password',
                          isLoading: authState.isLoading,
                          onPressed: _submit,
                          icon: LucideIcons.key,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
