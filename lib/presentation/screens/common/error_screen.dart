import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/error_view.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Occurred'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ErrorView(
        title: 'Unable to Load Screen',
        message: errorMessage ?? 'An unexpected error occurred while communicating with the database. Please try again or return to the dashboard.',
        onRetry: onRetry ?? () => context.go('/dashboard'),
      ),
    );
  }
}
