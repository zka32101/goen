import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// SplashScreen - App initialization and authentication routing
///
/// Displays loading animation while Firebase initializes and checks auth state.
/// Routes to:
/// - OnboardingScreen if first-time user
/// - HomeScreen if authenticated
/// - AuthScreen if not authenticated
class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building SplashScreen');

    // Watch authentication state
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Loading state
      loading: () {
        _logger.i('Auth state loading...');
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.sumiSurface,
                  AppColors.sumi,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.washi.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.kin,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 40,
                      color: AppColors.kin,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // App title
                  Text(
                    '碁縁',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.washi,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'GoEn - Premium Go Learning',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.kin,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.kin),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Initializing...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.washiDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // Error state
      error: (error, stack) {
        _logger.e('Auth state error: $error\n$stack');
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sumiSurface, AppColors.sumi],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.shuLight,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Initialization Error',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.washi,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.washiDim,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () {
                      // Retry by refreshing auth state
                      ref.refresh(authStateProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // Data state - user authenticated or not
      data: (user) {
        _logger.i('Auth state resolved: user=${user?.uid ?? "null"}');

        // If user is logged in, route to Home
        if (user != null) {
          _logger.i('User authenticated, routing to HomeScreen');
          // Navigate to HomeScreen (will be implemented in Phase 4)
          Future.microtask(() {
            _routeToHome(context);
          });
        } else {
          _logger.i('User not authenticated, routing to OnboardingScreen');
          // Navigate to OnboardingScreen (will be implemented in Phase 4)
          Future.microtask(() {
            _routeToOnboarding(context);
          });
        }

        // Show loading screen while navigation happens
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sumiSurface, AppColors.sumi],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.washi.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.kin,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 40,
                      color: AppColors.kin,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '碁縁',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.washi,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Route to HomeScreen
  void _routeToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  /// Route to OnboardingScreen
  void _routeToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }
}
