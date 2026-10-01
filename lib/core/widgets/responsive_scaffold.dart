import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_layout.dart';
import '../../presentation/providers/notification_provider.dart';
import '../../presentation/providers/sync_provider.dart';
import '../../presentation/screens/search/search_command_palette.dart';
import '../../presentation/screens/tasks/create_task_sheet.dart';
import 'offline_indicator.dart';
import 'taskflow_logo.dart';

class ResponsiveScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onNavigationItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/projects');
        break;
      case 3:
        context.go('/calendar');
        break;
      case 4:
        context.go('/analytics');
        break;
    }
  }

  void _openCommandPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SearchCommandPalette(),
    );
  }

  void _openQuickAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateTaskSheet(),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, ThemeData theme, bool isMobile) {
    if (!isMobile) return null;

    if (widget.currentIndex == 2) {
      // Projects tab: Dedicated New Project action button
      return FloatingActionButton.extended(
        key: const ValueKey('fab_new_project'),
        onPressed: () => context.push('/create-project'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.folderPlus, size: 20),
        label: const Text(
          'New Project',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    if (widget.currentIndex == 4) {
      // Analytics tab: Read-only report view
      return null;
    }

    // Default (Dashboard, Tasks, Calendar): Add task
    return FloatingActionButton(
      key: const ValueKey('fab_add_task'),
      onPressed: _openQuickAdd,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      tooltip: 'Add Task',
      child: const Icon(LucideIcons.plus, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final unreadNotifications = ref.watch(notificationProvider).unreadCount;
    final syncStatus = ref.watch(syncProvider).status;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _openCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _openCommandPalette,
      },
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        child: Scaffold(
          body: isMobile
              ? widget.child
              : Row(
                  children: [
                    // Desktop / Tablet Navigation Rail
                    Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        border: Border(
                          right: BorderSide(color: theme.colorScheme.outline, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TaskFlowLogo(size: 34),
                          ),
                          const SizedBox(height: 20),
                          // Search / Command Palette shortcut trigger
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: _openCommandPalette,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                  border: Border.all(color: theme.colorScheme.outline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.search, size: 16, color: theme.textTheme.bodySmall?.color),
                                    const SizedBox(width: 8),
                                    Text('Search...', style: theme.textTheme.bodySmall),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outline.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '⌘K',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              children: [
                                _NavTile(
                                  icon: LucideIcons.layoutDashboard,
                                  title: 'Dashboard',
                                  isSelected: widget.currentIndex == 0,
                                  onTap: () => _onNavigationItemTapped(0),
                                ),
                                _NavTile(
                                  icon: LucideIcons.checkSquare,
                                  title: 'All Tasks',
                                  isSelected: widget.currentIndex == 1,
                                  onTap: () => _onNavigationItemTapped(1),
                                ),
                                _NavTile(
                                  icon: LucideIcons.folder,
                                  title: 'Projects',
                                  isSelected: widget.currentIndex == 2,
                                  onTap: () => _onNavigationItemTapped(2),
                                ),
                                _NavTile(
                                  icon: LucideIcons.calendar,
                                  title: 'Calendar',
                                  isSelected: widget.currentIndex == 3,
                                  onTap: () => _onNavigationItemTapped(3),
                                ),
                                _NavTile(
                                  icon: LucideIcons.barChart2,
                                  title: 'Analytics',
                                  isSelected: widget.currentIndex == 4,
                                  onTap: () => _onNavigationItemTapped(4),
                                ),
                                const Divider(height: 24),
                                _NavTile(
                                  icon: LucideIcons.bell,
                                  title: 'Notifications',
                                  badgeCount: unreadNotifications,
                                  isSelected: false,
                                  onTap: () => context.push('/notifications'),
                                ),
                                _NavTile(
                                  icon: LucideIcons.users,
                                  title: 'Team',
                                  isSelected: false,
                                  onTap: () => context.push('/team'),
                                ),
                                _NavTile(
                                  icon: LucideIcons.settings,
                                  title: 'Settings',
                                  isSelected: false,
                                  onTap: () => context.push('/settings'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                OfflineIndicator(
                                  status: syncStatus,
                                  onTap: () => ref.read(syncProvider.notifier).toggleOfflineMode(),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openQuickAdd,
                                    icon: const Icon(LucideIcons.plus, size: 16),
                                    label: const Text('Add Task'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
          bottomNavigationBar: isMobile
              ? Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 1)),
                  ),
                  child: NavigationBar(
                    selectedIndex: widget.currentIndex,
                    onDestinationSelected: _onNavigationItemTapped,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(LucideIcons.layoutDashboard, size: 20),
                        label: 'Dashboard',
                      ),
                      NavigationDestination(
                        icon: Icon(LucideIcons.checkSquare, size: 20),
                        label: 'Tasks',
                      ),
                      NavigationDestination(
                        icon: Icon(LucideIcons.folder, size: 20),
                        label: 'Projects',
                      ),
                      NavigationDestination(
                        icon: Icon(LucideIcons.calendar, size: 20),
                        label: 'Calendar',
                      ),
                      NavigationDestination(
                        icon: Icon(LucideIcons.barChart2, size: 20),
                        label: 'Analytics',
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: _buildFloatingActionButton(context, theme, isMobile),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? primary : theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? primary : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
