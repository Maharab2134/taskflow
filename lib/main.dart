import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage & Preferences
  await StorageService.init();

  // Initialize Local Notifications
  await NotificationService.instance.init();

  // Initialize Supabase Client (Seamlessly handles both live credentials and offline/local fallback)
  await SupabaseService.instance.init();

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends ConsumerWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(primaryColor: themeState.accentColor),
      darkTheme: AppTheme.darkTheme(primaryColor: themeState.accentColor),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
