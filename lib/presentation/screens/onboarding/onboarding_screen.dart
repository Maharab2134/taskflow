import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/taskflow_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: LucideIcons.layers,
      title: 'Precision Task Management',
      description: 'Streamline your day with intelligent priorities, subtask progress tracking, and natural language quick-add.',
      accentColor: AppColors.primary,
    ),
    _OnboardingItem(
      icon: LucideIcons.kanban,
      title: 'Kanban Boards & Milestones',
      description: 'Visualize your team workflows. Drag and drop tasks effortlessly through To Do, In Progress, Review, and Done.',
      accentColor: AppColors.secondary,
    ),
    _OnboardingItem(
      icon: LucideIcons.shieldCheck,
      title: 'Offline Sync & Free Tier Supabase',
      description: 'Zero data loss with local caching. Sync automatically when online, backed by PostgreSQL Row Level Security.',
      accentColor: AppColors.completed,
    ),
  ];

  void _finishOnboarding() async {
    await StorageService.setOnboardingCompleted();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TaskFlowLogo(size: 32),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                item.accentColor.withOpacity(0.18),
                                item.accentColor.withOpacity(0.04),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: item.accentColor.withOpacity(0.3), width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 52,
                              color: item.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(_items.length, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: AppConstants.animFast,
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  AppButton(
                    width: _currentPage == _items.length - 1 ? 148 : 96,
                    label: _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                    icon: _currentPage == _items.length - 1 ? LucideIcons.arrowRight : null,
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: AppConstants.animNormal,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
