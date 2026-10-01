import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        children: [
          Text('THEME MODE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeState.themeMode,
                  title: const Text('System Default'),
                  subtitle: const Text('Match device light/dark appearance'),
                  secondary: const Icon(LucideIcons.smartphone, size: 20),
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeProvider.notifier).setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeState.themeMode,
                  title: const Text('Light Mode'),
                  subtitle: const Text('Clean crisp Nordic aesthetics'),
                  secondary: const Icon(LucideIcons.sun, size: 20),
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeProvider.notifier).setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeState.themeMode,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('High-contrast Obsidian slate interface'),
                  secondary: const Icon(LucideIcons.moon, size: 20),
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeProvider.notifier).setThemeMode(mode);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('PRIMARY BRAND ACCENT', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your personal workflow accent color:',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: AppColors.themePresets.map((color) {
                    final isSelected = themeState.accentColor.value == color.value;
                    return GestureDetector(
                      onTap: () => ref.read(themeProvider.notifier).setAccentColor(color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(isSelected ? 0.6 : 0.25),
                              blurRadius: isSelected ? 12 : 4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Center(child: Icon(LucideIcons.check, size: 18, color: Colors.white))
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Preview Card
          Text('LIVE PREVIEW', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeState.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(LucideIcons.checkCircle2, color: themeState.accentColor, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sample Task Card Preview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text('This is how active elements will render', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themeState.accentColor),
                  onPressed: () {},
                  child: const Text('Action'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
