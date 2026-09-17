import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/enums.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) => _SettingsList(settings: settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  final AppSettings settings;
  const _SettingsList({required this.settings});

  void _update(WidgetRef ref, AppSettings updated) {
    ref.read(settingsProvider.notifier).updateSettings(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Appearance section
        _SectionHeader('Appearance'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                subtitle: Text(_themeLabel(settings.themeModePreference)),
                trailing: SegmentedButton<ThemeModePreference>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeModePreference.system,
                      icon: Icon(Icons.settings_brightness),
                    ),
                    ButtonSegment(
                      value: ThemeModePreference.light,
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeModePreference.dark,
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {settings.themeModePreference},
                  onSelectionChanged: (s) => _update(
                    ref,
                    settings.copyWith(themeModePreference: s.first),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Practice defaults section
        _SectionHeader('Practice Defaults'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.quiz_outlined),
                title: const Text('Default Question Count'),
                trailing: DropdownButton<int>(
                  value: settings.questionCount,
                  underline: const SizedBox.shrink(),
                  items: AppConstants.questionCountOptions
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                  onChanged: (v) => _update(ref, settings.copyWith(questionCount: v)),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.timer_outlined),
                title: const Text('Timed Mode by Default'),
                value: settings.timedMode,
                onChanged: (v) => _update(ref, settings.copyWith(timedMode: v)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.hourglass_bottom_outlined),
                title: const Text('Default Time Limit'),
                enabled: settings.timedMode,
                trailing: DropdownButton<int>(
                  value: settings.timeLimitSeconds,
                  underline: const SizedBox.shrink(),
                  onChanged: settings.timedMode
                      ? (v) => _update(ref, settings.copyWith(timeLimitSeconds: v))
                      : null,
                  items: AppConstants.timeLimitOptions
                      .map((n) => DropdownMenuItem(value: n, child: Text('${n}s')))
                      .toList(),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Feedback Mode'),
                trailing: SegmentedButton<FeedbackMode>(
                  segments: const [
                    ButtonSegment(value: FeedbackMode.instant, label: Text('Rapid')),
                    ButtonSegment(value: FeedbackMode.endOfSession, label: Text('End')),
                  ],
                  selected: {settings.feedbackMode},
                  onSelectionChanged: (s) => _update(ref, settings.copyWith(feedbackMode: s.first)),
                ),
              ),
            ],
          ),
        ),

        // About section
        _SectionHeader('About'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('MentalMath'),
                subtitle: const Text('Version 1.0.0'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calculate_outlined),
                title: const Text('About'),
                subtitle: const Text(
                  'A mental mathematics practice app designed to improve fast calculation skills through structured learning and practice.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String _themeLabel(ThemeModePreference pref) {
    switch (pref) {
      case ThemeModePreference.system: return 'System';
      case ThemeModePreference.light: return 'Light';
      case ThemeModePreference.dark: return 'Dark';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
