import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Identity (Default: Modern Electric Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFF312E81);

  // Secondary Accents
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color tertiary = Color(0xFF8B5CF6);

  // Semantic Status Colors
  static const Color todo = Color(0xFF64748B);
  static const Color inProgress = Color(0xFFF59E0B);
  static const Color inReview = Color(0xFF8B5CF6);
  static const Color completed = Color(0xFF10B981);
  static const Color archived = Color(0xFF94A3B8);

  // Priority Colors
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityUrgent = Color(0xFFEF4444);

  // Dark Theme Backgrounds & Surfaces (Obsidian Slate Palette)
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A2234);
  static const Color darkCardElevated = Color(0xFF222D42);
  static const Color darkBorder = Color(0xFF2E384D);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Backgrounds & Surfaces (Nordic Ice Palette)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Color preset options for custom themes
  static const List<Color> themePresets = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFF43F5E), // Rose
  ];
}
