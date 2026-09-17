import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'models/enums.dart';
import 'providers/settings_provider.dart';
import 'providers/session_provider.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/practice/practice_home_screen.dart';
import 'features/practice/practice_session_screen.dart';
import 'features/practice/practice_results_screen.dart';
import 'features/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _AppShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeHomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Full-screen routes outside the shell
    GoRoute(
      path: '/practice/session',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final opIndex = extra['operation'] as int? ?? 0;
        final diffIndex = extra['difficulty'] as int? ?? 0;
        final count = extra['count'] as int? ?? 10;
        final timed = extra['timed'] as bool? ?? false;
        final timeLimit = extra['timeLimit'] as int? ?? 20;
        final feedbackIndex = extra['feedback'] as int? ?? 0;

        return PracticeSessionScreen(
          operation: Operation.values[opIndex],
          difficulty: DifficultyLevel.values[diffIndex],
          questionCount: count,
          timedMode: timed,
          timeLimitSeconds: timeLimit,
          feedbackMode: FeedbackMode.values[feedbackIndex],
        );
      },
    ),
    GoRoute(
      path: '/practice/results',
      builder: (context, state) {
        final sessionState = state.extra as SessionState? ?? const SessionState();
        return PracticeResultsScreen(sessionState: sessionState);
      },
    ),
  ],
);

int _selectedIndex(String location) {
  if (location.startsWith('/learn')) return 1;
  if (location.startsWith('/practice')) return 2;
  if (location.startsWith('/settings')) return 3;
  return 0;
}

class _AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const _AppShell({required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0: context.go('/'); break;
            case 1: context.go('/learn'); break;
            case 2: context.go('/practice'); break;
            case 3: context.go('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class MentalMathApp extends ConsumerWidget {
  const MentalMathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        ThemeMode themeMode = ThemeMode.system;
        if (settings.themeModePreference == ThemeModePreference.light) {
          themeMode = ThemeMode.light;
        } else if (settings.themeModePreference == ThemeModePreference.dark) {
          themeMode = ThemeMode.dark;
        }

        return MaterialApp.router(
          title: 'MentalMath',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      ),
      error: (_, _) => const MaterialApp(
        home: Scaffold(body: Center(child: Text('Error loading settings'))),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
