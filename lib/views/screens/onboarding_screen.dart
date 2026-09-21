import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// OnboardingScreen - 3-card rule tutorial for new users
///
/// Teaches the fundamental "3-tap Aha" moment:
/// 1. Place black stone (player's first move)
/// 2. AI responds with white stone
/// 3. Capture the AI's stone with a second black stone
///
/// Routes to HomeScreen after completion
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _logger.i('OnboardingScreen initialized');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sumi,
      body: Column(
        children: [
          // Header with skip button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Learn Go',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.washi,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _handleSkipTutorial,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.kin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView for cards
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildCard1_Welcome(context),
                _buildCard2_YourMove(context),
                _buildCard3_Capture(context),
              ],
            ),
          ),

          // Dots indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? AppColors.kin
                        : AppColors.grey500,
                  ),
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage < 2
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : _handleCompleteTutorial,
                    child: Text(
                      _currentPage < 2 ? 'Next' : 'Start Playing',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card 1: Welcome & motivation
  Widget _buildCard1_Welcome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 120, color: AppColors.kin),
            const SizedBox(height: 32),
            Text(
              'Welcome to 碁縁',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.washi,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Learn Go at your own pace. No time pressure, just pure strategy.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.washiDim,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.kin, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'We\'ll teach you the basics in 3 simple steps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.kin,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card 2: Your first move
  Widget _buildCard2_YourMove(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap 1: Your Move',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.washi,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mini board visualization
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.kin, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.kinLight.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  // Grid lines
                  CustomPaint(
                    painter: _GoGridPainter(),
                    size: const Size(200, 200),
                  ),
                  // Black stone
                  Positioned(
                    left: 75,
                    top: 75,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sumi,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Annotation arrow
                  Positioned(
                    right: -20,
                    top: 80,
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.kin,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Place your first black stone anywhere on the board.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.washiDim,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Card 3: Capture the stone
  Widget _buildCard3_Capture(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap 3: Capture!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.washi,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The Aha Moment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.kin,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mini board visualization
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.kin, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.kinLight.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  // Grid lines
                  CustomPaint(
                    painter: _GoGridPainter(),
                    size: const Size(200, 200),
                  ),
                  // White stone (AI's move)
                  Positioned(
                    left: 100,
                    top: 75,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.washi,
                        border: Border.all(color: AppColors.sumi, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Black stone (player's capture)
                  Positioned(
                    left: 100,
                    top: 50,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sumi,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Original black stone
                  Positioned(
                    left: 75,
                    top: 75,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sumi,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'AI plays white. Now place your second black stone to surround and capture the white stone. This is the fundamental tactic in Go!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.washiDim,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSkipTutorial() {
    _logger.i('Tutorial skipped');
    ref.read(logTutorialSkippedProvider)();
    _navigateToHome();
  }

  void _handleCompleteTutorial() async {
    _logger.i('Tutorial completed');
    try {
      await ref.read(logTutorialCompletedProvider)();
      await ref.read(completeTutorialProvider)();
    } catch (e) {
      _logger.e('Error completing tutorial: $e');
    }
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await _ensureSignedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _ensureSignedIn() async {
    try {
      final authService = ref.read(authServiceProvider);
      if (authService.currentUser != null) return;
      await authService.signInAnonymously().timeout(const Duration(seconds: 8));
    } catch (e) {
      _logger.w('Anonymous sign-in failed, continuing as guest: $e');
    }
  }
}

/// Custom painter for Go board grid
class _GoGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey500
      ..strokeWidth = 1;

    final step = size.width / 4;

    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), paint);
    }

    // Vertical lines
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(i * step, 0),
        Offset(i * step, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoGridPainter oldDelegate) => false;
}
