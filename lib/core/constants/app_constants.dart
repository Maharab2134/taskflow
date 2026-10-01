class AppConstants {
  AppConstants._();

  static const String appName = 'TaskFlow';
  static const String appTagline = 'Master your workflow with precision';
  static const String appVersion = '1.0.0';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Spacing & Border Radii
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 28.0;

  // Animation Timers
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Storage / SharedPreferences Keys
  static const String keyThemeMode = 'taskflow_theme_mode';
  static const String keyAccentColor = 'taskflow_accent_color';
  static const String keyOnboardingCompleted = 'taskflow_onboarding_done';
  static const String keyOfflineTasks = 'taskflow_cached_tasks';
  static const String keyOfflineProjects = 'taskflow_cached_projects';
  static const String keyNotificationSettings = 'taskflow_notification_settings';

  // Supabase Defaults (Can be overridden by .env or remote config)
  static const String defaultSupabaseUrl = 'https://demo-project-taskflow.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_for_demo';
}
