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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
      if (success && mounted) {
        AppToast.showSuccess(context, 'Password reset link sent to your email!');
        setState(() => _sent = true);
      } else if (mounted) {
        final err = ref.read(authProvider).errorMessage ?? 'Failed to send reset email.';
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
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _sent
                ? GlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacing24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.mailCheck, size: 32, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 20),
                        Text('Reset link sent!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                          'We sent instructions to ${_emailController.text.trim()}. Check your inbox and spam folder.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Back to Sign In',
                          onPressed: () => context.go('/login'),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Reset Password', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your account email and we\'ll send you a password recovery link.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                        ),
                        const SizedBox(height: 24),
                        GlassCard(
                          padding: const EdgeInsets.all(AppConstants.spacing20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                label: 'Email Address',
                                hint: 'alex@example.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: LucideIcons.mail,
                                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                label: 'Send Recovery Link',
                                isLoading: authState.isLoading,
                                onPressed: _submit,
                                icon: LucideIcons.send,
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
