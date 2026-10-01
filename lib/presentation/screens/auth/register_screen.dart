import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/taskflow_logo.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_agreedToTerms) {
      AppToast.showWarning(context, 'Please accept the Terms & Privacy policy');
      return;
    }

    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim(),
          );
      if (success && mounted) {
        context.push('/email-verification', extra: _emailController.text.trim());
      } else if (mounted) {
        final err = ref.read(authProvider).errorMessage ?? 'Registration failed.';
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TaskFlowLogo(size: 44)),
                  const SizedBox(height: 20),
                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join thousands of high performers managing tasks with TaskFlow',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacing20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Alex Vance',
                          controller: _nameController,
                          prefixIcon: LucideIcons.user,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Work Email',
                          hint: 'alex@company.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: LucideIcons.mail,
                          validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: LucideIcons.lock,
                          validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Confirm Password',
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Create Account',
                          isLoading: authState.isLoading,
                          onPressed: _submit,
                          icon: LucideIcons.userPlus,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: theme.textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
