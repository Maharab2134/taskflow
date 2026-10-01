import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';

class AppToast {
  AppToast._();

  /// Converts any exception or error into clean, human-readable toast message.
  static String cleanMessage(dynamic error) {
    if (error == null) return 'Something went wrong. Please try again.';
    String text = error.toString();

    // 1. Extract message: value if Supabase AuthApiException format
    // e.g. AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)
    final msgRegex = RegExp(r'message:\s*([^,\)]+)');
    final match = msgRegex.firstMatch(text);
    if (match != null) {
      final extracted = match.group(1)?.trim();
      if (extracted != null && extracted.isNotEmpty) {
        text = extracted;
      }
    }

    // 2. Strip Exception class names and prefixes
    text = text.replaceAll(RegExp(r'^(Exception|AuthApiException|AuthException|PostgrestException):\s*'), '');

    // 3. User-friendly mapping for common auth & database errors
    final lower = text.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email before logging in. Check your inbox.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered') ||
        lower.contains('user_already_exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password should be at least') || lower.contains('password is too short')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('over_request_rate_limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    if (lower.contains('email link is invalid') || lower.contains('token has expired')) {
      return 'The verification or reset link has expired. Please request a new one.';
    }

    // 4. Clean any residual punctuation or braces
    text = text.trim();
    if (text.endsWith(')')) text = text.substring(0, text.length - 1);
    if (text.startsWith('{') && text.endsWith('}')) {
      text = text.substring(1, text.length - 1).trim();
    }

    return text.isNotEmpty ? text : 'An unexpected error occurred. Please try again.';
  }

  /// Display a floating Error Toast
  static void showError(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = cleanMessage(error);
    _showFloatingToast(
      context: context,
      message: message,
      icon: LucideIcons.circleAlert,
      accentColor: AppColors.error,
      duration: duration,
    );
  }

  /// Display a floating Success Toast
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingToast(
      context: context,
      message: message,
      icon: LucideIcons.circleCheck,
      accentColor: AppColors.success,
      duration: duration,
    );
  }

  /// Display a floating Info Toast
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingToast(
      context: context,
      message: message,
      icon: LucideIcons.info,
      accentColor: AppColors.info,
      duration: duration,
    );
  }

  /// Display a floating Warning Toast
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingToast(
      context: context,
      message: message,
      icon: LucideIcons.triangleAlert,
      accentColor: AppColors.warning,
      duration: duration,
    );
  }

  static void _showFloatingToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF161F30) : const Color(0xFF0F172A);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
