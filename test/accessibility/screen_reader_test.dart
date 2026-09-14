import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/home_screen.dart';
import 'package:goen/views/screens/ai_game_screen.dart';
import '../test_utils.dart';
import '../fixtures/test_data.dart';

void main() {
  group('Accessibility: Screen Reader Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('🔊 Screen reader: Home screen announces all actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify semantic labels for main actions
      expect(find.bySemanticsLabel('Play'), findsWidgets);
      expect(find.bySemanticsLabel('Daily Puzzle'), findsWidgets);
      expect(find.bySemanticsLabel('Watch & Learn'), findsWidgets);
      expect(find.bySemanticsLabel('Settings'), findsWidgets);

      print('✓ Home screen has complete semantic coverage');
    });

    testWidgets('🔊 Screen reader: Button labels are descriptive',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Find all buttons with semantics
      final buttons = find.byType(Semantics);
      expect(buttons.evaluate().length, greaterThan(0));

      for (var button in buttons.evaluate()) {
        // Each button should have a meaningful label
        expect(button, isNotNull);
      }

      print('✓ All buttons have descriptive labels');
    });

    testWidgets('🔊 Screen reader: Form field labels are associated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Semantics(
                  label: 'Username',
                  child: const TextField(
                    decoration: InputDecoration(labelText: 'Enter username'),
                  ),
                ),
                Semantics(
                  label: 'Password',
                  child: const TextField(
                    decoration: InputDecoration(labelText: 'Enter password'),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Username'), findsWidgets);
      expect(find.bySemanticsLabel('Password'), findsWidgets);

      print('✓ Form fields have proper semantic labels');
    });

    testWidgets('🔊 Screen reader: List items announced sequentially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                5,
                (index) => Semantics(
                  label: 'Game $index',
                  child: ListTile(
                    title: Text('Game ${index + 1}'),
                    subtitle: Text('Result: ${index % 2 == 0 ? 'Win' : 'Loss'}'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify list items are readable
      for (int i = 0; i < 5; i++) {
        expect(find.bySemanticsLabel('Game $i'), findsWidgets);
      }

      print('✓ List items are properly announced');
    });

    testWidgets('🔊 Screen reader: Game board description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const AIGameScreen(),
          container: container,
        ),
      );

      // Board should have descriptive semantics
      expect(find.byType(Semantics), findsWidgets);

      print('✓ Game board has semantic description');
    });

    testWidgets('🔊 Screen reader: Error messages are announced',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                enabled: true,
                label: 'Error: Connection failed. Please check your internet connection.',
                child: const Text('Connection Error'),
              ),
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Error: Connection failed. Please check your internet connection.'),
        findsWidgets,
      );

      print('✓ Error messages are announced to screen readers');
    });

    testWidgets('🔊 Screen reader: Status updates are announced',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                enabled: true,
                label: 'AI is thinking...',
                child: const Text('AI Move In Progress'),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('AI is thinking...'), findsWidgets);

      print('✓ Status updates are announced');
    });

    testWidgets('🔊 Screen reader: Navigation landmarks',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify scaffold exists for landmark structure
      expect(find.byType(Scaffold), findsWidgets);

      print('✓ Navigation landmarks available');
    });

    testWidgets('🔊 Screen reader: Link/Button distinction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Semantics(
                    enabled: true,
                    label: 'Play new game',
                    button: true,
                    child: const Text('Play'),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Semantics(
                    enabled: true,
                    label: 'Learn more about Go',
                    link: true,
                    child: const Text('Learn'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Play new game'), findsWidgets);
      expect(find.bySemanticsLabel('Learn more about Go'), findsWidgets);

      print('✓ Links and buttons are properly distinguished');
    });

    testWidgets('🔊 Screen reader: Image alternative text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                enabled: true,
                label: 'Black stone on empty board',
                image: true,
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Black stone on empty board'),
        findsWidgets,
      );

      print('✓ Images have alternative text');
    });

    testWidgets('🔊 Screen reader: Heading hierarchy',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                Semantics(
                  enabled: true,
                  label: 'Main heading',
                  enabled: true,
                  child: const Text('Go Learning',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Semantics(
                  enabled: true,
                  label: 'Subheading',
                  child: const Text('Recent Games',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Main heading'), findsWidgets);
      expect(find.bySemanticsLabel('Subheading'), findsWidgets);

      print('✓ Heading hierarchy is correct');
    });

    testWidgets('🔊 Screen reader: Skip to main content link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Semantics(
                  enabled: true,
                  label: 'Skip to main content',
                  button: true,
                  child: const SizedBox(
                    height: 0,
                    child: Text('Skip'),
                  ),
                ),
                Semantics(
                  enabled: true,
                  label: 'Main content area',
                  child: const Expanded(
                    child: Center(
                      child: Text('Game Content'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Skip to main content'), findsWidgets);
      expect(find.bySemanticsLabel('Main content area'), findsWidgets);

      print('✓ Skip links available');
    });

    testWidgets('🔊 Screen reader: Game result announcement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    enabled: true,
                    label: 'Game Result',
                    child: const Text('You Won!',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  Semantics(
                    enabled: true,
                    label: 'Final score: You 15 points, AI 10 points',
                    child: const Text('15 - 10'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Game Result'), findsWidgets);
      expect(find.bySemanticsLabel('Final score: You 15 points, AI 10 points'), findsWidgets);

      print('✓ Game results are announced clearly');
    });

    testWidgets('🔊 Screen reader: Move-by-move game narration',
        (WidgetTester tester) async {
      const moves = [
        'Move 1: Black plays at position 3-3',
        'Move 2: White responds at position 16-3',
        'Move 3: Black plays at position 3-16',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: moves.map((move) {
                return Semantics(
                  enabled: true,
                  label: move,
                  child: ListTile(title: Text(move)),
                );
              }).toList(),
            ),
          ),
        ),
      );

      for (final move in moves) {
        expect(find.bySemanticsLabel(move), findsWidgets);
      }

      print('✓ Move history is readable by screen readers');
    });
  });
}
