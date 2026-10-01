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

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerifyCode() async {
    final token = _otpController.text.trim();
    if (token.isEmpty) {
      AppToast.showWarning(context, 'Please enter the verification code or token');
      return;
    }

    final targetEmail = widget.email?.trim() ?? '';
    if (targetEmail.isEmpty) {
      AppToast.showWarning(context, 'No email specified. Please return to Sign In.');
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyEmailOtp(
          email: targetEmail,
          token: token,
        );

    if (mounted) {
      if (success) {
        AppToast.showSuccess(context, 'Email verified successfully! Welcome to TaskFlow.');
        context.go('/dashboard');
      } else {
        final err = ref.read(authProvider).errorMessage ?? 'Invalid verification code. Please check your email.';
        AppToast.showError(context, err);
      }
    }
  }

  void _onResend() async {
    final targetEmail = widget.email?.trim() ?? '';
    if (targetEmail.isEmpty) return;

    setState(() => _isResending = true);
    final success = await ref.read(authProvider.notifier).resendVerificationEmail(targetEmail);
    if (mounted) {
      setState(() => _isResending = false);
      if (success) {
        AppToast.showSuccess(context, 'Verification email re-sent! Check your inbox.');
      } else {
        AppToast.showError(context, 'Could not resend at this moment. Please try again shortly.');
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
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassCard(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.mailCheck, size: 36, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a confirmation link and code to:\n${widget.email ?? 'your email'}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Option A: Enter 6-digit Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter 6-digit code from email',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          label: 'Verification Code',
                          hint: 'e.g. 123456 or token',
                          controller: _otpController,
                          prefixIcon: LucideIcons.keyRound,
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Verify Code',
                          isLoading: authState.isLoading,
                          onPressed: _onVerifyCode,
                          icon: LucideIcons.checkCheck,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Option B: Already clicked the link in email
                  OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(LucideIcons.logIn, size: 16),
                    label: const Text('Confirmed via Email Link? Sign In'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _isResending ? null : _onResend,
                    icon: _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.refreshCw, size: 14),
                    label: Text(_isResending ? 'Resending...' : 'Resend Verification Email'),
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
