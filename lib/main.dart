import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'views/screens/index.dart';

final _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  _logger.i('Firebase initialized');

  runApp(
    const ProviderScope(
      child: GoEnApp(),
    ),
  );
}

class GoEnApp extends ConsumerWidget {
  const GoEnApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GoEn - 碁縁',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Dark mode only for premium adults
      home: const SplashScreen(),
      navigatorObservers: [
        _AnalyticsNavigatorObserver(),
      ],
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/ai-game': (_) => const AIGameScreen(),
        '/game-result': (_) => GameResultScreenRouter(),
        // Future screens (Phase 5)
        '/tsume-go': (_) => const TsumeGoScreen(),
        '/kifu-observation': (_) => const KifuObservationScreen(),
        '/game-history': (_) => const GameHistoryScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/paywall': (_) => const PaywallScreen(),
      },
      onUnknownRoute: (_) {
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen('Not Found'),
        );
      },
    );
  }
}

/// Router for GameResultScreen - handles arguments
class GameResultScreenRouter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;

    return GameResultScreen(
      result: args?['result'] ?? 'unknown',
      blackScore: args?['blackScore'] as double?,
      whiteScore: args?['whiteScore'] as double?,
    );
  }
}

/// Placeholder screen for features not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This screen is under development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Analytics observer for tracking screen views
class _AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.i('Screen pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.i('Screen popped: ${route.settings.name}');
  }
}
