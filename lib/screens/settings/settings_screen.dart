import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: RadioGroup<ThemeMode>(
              groupValue: themeProvider.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    title: 'System Default',
                    subtitle: 'Follow your device theme',
                    icon: Icons.brightness_auto_rounded,
                    mode: ThemeMode.system,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context,
                    title: 'Light',
                    subtitle: 'Use light theme',
                    icon: Icons.light_mode_rounded,
                    mode: ThemeMode.light,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context,
                    title: 'Dark',
                    subtitle: 'Use dark theme',
                    icon: Icons.dark_mode_rounded,
                    mode: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Radio<ThemeMode>(value: mode),
    );
  }
}
