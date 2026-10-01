import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/profile_model.dart';

// Screens
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/email_verification_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';

import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/tasks/all_tasks_screen.dart';
import '../../presentation/screens/tasks/my_tasks_screen.dart';
import '../../presentation/screens/tasks/today_tasks_screen.dart';
import '../../presentation/screens/tasks/upcoming_tasks_screen.dart';
import '../../presentation/screens/tasks/task_details_screen.dart';
import '../../presentation/screens/tasks/edit_task_screen.dart';
import '../../presentation/screens/tasks/subtasks_screen.dart';
import '../../presentation/screens/tasks/task_comments_screen.dart';
import '../../presentation/screens/tasks/task_attachments_screen.dart';
import '../../presentation/screens/tasks/archived_tasks_screen.dart';
import '../../presentation/screens/tasks/trash_screen.dart';

import '../../presentation/screens/projects/projects_screen.dart';
import '../../presentation/screens/projects/project_details_screen.dart';
import '../../presentation/screens/projects/create_project_screen.dart';
import '../../presentation/screens/projects/edit_project_screen.dart';

import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/analytics/productivity_stats_screen.dart';
import '../../presentation/screens/team/team_screen.dart';
import '../../presentation/screens/team/team_members_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';

import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/appearance_screen.dart';
import '../../presentation/screens/settings/notification_settings_screen.dart';
import '../../presentation/screens/settings/security_settings_screen.dart';
import '../../presentation/screens/settings/data_privacy_screen.dart';
import '../../presentation/screens/settings/help_support_screen.dart';
import '../../presentation/screens/settings/about_screen.dart';

import '../../presentation/screens/common/empty_states_gallery_screen.dart';
import '../../presentation/screens/common/error_screen.dart';
import '../../presentation/screens/common/offline_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => EmailVerificationScreen(email: state.extra as String?),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // 4. Main Navigation Shell (ResponsiveScaffold)
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final location = state.uri.toString();
          if (location.startsWith('/tasks')) {
            index = 1;
          } else if (location.startsWith('/projects')) {
            index = 2;
          } else if (location.startsWith('/calendar')) {
            index = 3;
          } else if (location.startsWith('/analytics')) {
            index = 4;
          }
          return ResponsiveScaffold(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => const NoTransitionPage(child: AllTasksScreen()),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProjectsScreen()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(child: CalendarScreen()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(child: AnalyticsScreen()),
          ),
        ],
      ),

      // 5. Tasks Extra Routes
      GoRoute(
        path: '/my-tasks',
        builder: (context, state) => const MyTasksScreen(),
      ),
      GoRoute(
        path: '/today',
        builder: (context, state) => const TodayTasksScreen(),
      ),
      GoRoute(
        path: '/upcoming',
        builder: (context, state) => const UpcomingTasksScreen(),
      ),
      GoRoute(
        path: '/task-details',
        builder: (context, state) => TaskDetailsScreen(task: state.extra as TaskModel),
      ),
      GoRoute(
        path: '/edit-task',
        builder: (context, state) => EditTaskScreen(task: state.extra as TaskModel),
      ),
      GoRoute(
        path: '/subtasks',
        builder: (context, state) => SubtasksScreen(task: state.extra as TaskModel),
      ),
      GoRoute(
        path: '/task-comments',
        builder: (context, state) => TaskCommentsScreen(task: state.extra as TaskModel),
      ),
      GoRoute(
        path: '/task-attachments',
        builder: (context, state) => TaskAttachmentsScreen(task: state.extra as TaskModel),
      ),
      GoRoute(
        path: '/archived-tasks',
        builder: (context, state) => const ArchivedTasksScreen(),
      ),
      GoRoute(
        path: '/trash',
        builder: (context, state) => const TrashScreen(),
      ),

      // 6. Projects Extra Routes
      GoRoute(
        path: '/project-details',
        builder: (context, state) => ProjectDetailsScreen(project: state.extra as ProjectModel),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/edit-project',
        builder: (context, state) => EditProjectScreen(project: state.extra as ProjectModel),
      ),

      // 7. Team & Analytics Extra Routes
      GoRoute(
        path: '/team',
        builder: (context, state) => const TeamScreen(),
      ),
      GoRoute(
        path: '/team-members',
        builder: (context, state) => const TeamMembersScreen(),
      ),
      GoRoute(
        path: '/productivity-stats',
        builder: (context, state) => const ProductivityStatsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // 8. Profile & Settings Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => EditProfileScreen(profile: state.extra as ProfileModel),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/data-privacy',
        builder: (context, state) => const DataPrivacyScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),

      // 9. Common System Routes
      GoRoute(
        path: '/empty-states',
        builder: (context, state) => const EmptyStatesGalleryScreen(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => ErrorScreen(errorMessage: state.extra as String?),
      ),
      GoRoute(
        path: '/offline',
        builder: (context, state) => const OfflineScreen(),
      ),
    ],
  );
});
