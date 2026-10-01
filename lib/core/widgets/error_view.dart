import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred while processing your request. Please try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withOpacity(0.25), width: 1.5),
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacing24),
              AppButton(
                label: 'Try Again',
                onPressed: onRetry,
                icon: LucideIcons.refreshCw,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
