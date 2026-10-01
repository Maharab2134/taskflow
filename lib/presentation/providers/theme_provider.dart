import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color accentColor;

  ThemeState({
    required this.themeMode,
    required this.accentColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(
      themeMode: _parseThemeMode(StorageService.getThemeMode()),
      accentColor: _parseColor(StorageService.getAccentColor()),
    );
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    String str = 'system';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    StorageService.saveThemeMode(str);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    StorageService.saveAccentColor(hex);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
