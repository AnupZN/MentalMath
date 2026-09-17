import os

base_dir = "/home/reed/Coding/MentalMath"

files = {
    "lib/main.dart": """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MentalMathApp(),
    ),
  );
}
""",

    "lib/app.dart": """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'models/enums.dart';
import 'providers/settings_provider.dart';
import 'features/home/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _calculateSelectedIndex(state.uri.path),
            onDestinationSelected: (idx) {
              switch (idx) {
                case 0: context.go('/'); break;
                case 1: context.go('/learn'); break;
                case 2: context.go('/practice'); break;
                case 3: context.go('/settings'); break;
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.book), label: 'Learn'),
              NavigationDestination(icon: Icon(Icons.sports_score), label: 'Practice'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Learn'))),
        ),
        GoRoute(
          path: '/practice',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Practice'))),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Settings'))),
        ),
      ],
    ),
  ],
);

int _calculateSelectedIndex(String location) {
  if (location.startsWith('/learn')) return 1;
  if (location.startsWith('/practice')) return 2;
  if (location.startsWith('/settings')) return 3;
  return 0;
}

class MentalMathApp extends ConsumerWidget {
  const MentalMathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return settingsAsync.when(
      data: (settings) {
        ThemeMode themeMode = ThemeMode.system;
        if (settings.themeModePreference == ThemeModePreference.light) themeMode = ThemeMode.light;
        if (settings.themeModePreference == ThemeModePreference.dark) themeMode = ThemeMode.dark;

        return MaterialApp.router(
          title: 'MentalMath',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          routerConfig: router,
        );
      },
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (_, __) => const MaterialApp(home: Scaffold(body: Center(child: Text('Error loading settings')))),
    );
  }
}
""",

    "lib/features/home/home_screen.dart": """import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MentalMath')),
      body: const Center(child: Text('Home Screen')),
    );
  }
}
"""
}

for path, content in files.items():
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w") as f:
        f.write(content)
