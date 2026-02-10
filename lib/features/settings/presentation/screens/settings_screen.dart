import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/features/settings/presentation/providers/settings_providers.dart';
import 'package:storelytics/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? Colors.black26 : Colors.white60,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle background gradient for non-dark mode
          if (!isDark)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blueGrey.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

          ListView(
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 100),
            children: [
              _buildSectionHeader('APPEARANCE'),
              const SizedBox(height: 12),
              _buildModernCard(
                isDark: isDark,
                children: [
                  _buildThemeOption(
                    ref: ref,
                    title: 'Light Aesthetic',
                    icon: Icons.wb_sunny_rounded,
                    mode: ThemeMode.light,
                    currentMode: themeMode,
                  ),
                  _buildDivider(isDark),
                  _buildThemeOption(
                    ref: ref,
                    title: 'Midnight Mode',
                    icon: Icons.nightlight_round,
                    mode: ThemeMode.dark,
                    currentMode: themeMode,
                  ),
                  _buildDivider(isDark),
                  _buildThemeOption(
                    ref: ref,
                    title: 'System Intelligence',
                    icon: Icons.settings_suggest_rounded,
                    mode: ThemeMode.system,
                    currentMode: themeMode,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('APPLICATION INFO'),
              const SizedBox(height: 12),
              _buildModernCard(
                isDark: isDark,
                children: [
                  _buildAboutTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    trailing: '1.2.0-stable',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildAboutTile(
                    icon: Icons.gavel_rounded,
                    title: 'Legal Metadata',
                    subtitle: 'Terms & Conditions',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildAboutTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Security & Privacy',
                    subtitle: 'Data usage policies',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Powered by Storelytics Intelligent Engine',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.3,
                    ),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.secondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeOption({
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    return ListTile(
      onTap: () => ref.read(themeModeProvider.notifier).state = mode,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.secondary : Colors.grey,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      trailing:
          isSelected
              ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondary,
                size: 24,
              )
              : const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
    );
  }

  Widget _buildAboutTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: isDark ? Colors.white54 : Colors.black54,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle:
          subtitle != null
              ? Text(subtitle, style: const TextStyle(fontSize: 12))
              : null,
      trailing:
          trailing != null
              ? Text(
                trailing,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              )
              : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
    );
  }
}
