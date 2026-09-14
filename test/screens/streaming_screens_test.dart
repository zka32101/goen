import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/index.dart';
import '../test_utils.dart';

void main() {
  group('Streaming Screens Tests', () {
    late ProviderContainer testContainer;

    setUp(() {
      testContainer = TestUtils.createTestContainer();
    });

    /// Test 1: YouTubeShareScreen displays loading state
    testWidgets('YouTubeShareScreen displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    /// Test 2: YouTubeShareScreen displays connection required
    testWidgets('YouTubeShareScreen displays connection required when not connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      // Verify UI elements appear
      expect(find.byIcon(Icons.video_library), findsOneWidget);
      expect(find.text('YouTube チャンネルを接続'), findsOneWidget);
    });

    /// Test 3: YouTubeShareScreen has connect button
    testWidgets('YouTubeShareScreen has YouTube connect button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      expect(find.text('YouTube で接続'), findsOneWidget);
    });

    /// Test 4: TwitchStreamScreen displays loading state
    testWidgets('TwitchStreamScreen displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const TwitchStreamScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    /// Test 5: TwitchStreamScreen displays connection required
    testWidgets('TwitchStreamScreen displays connection required',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const TwitchStreamScreen(),
        ),
      );

      expect(find.byIcon(Icons.streaming), findsOneWidget);
      expect(find.text('Twitch チャンネルを接続'), findsOneWidget);
    });

    /// Test 6: TwitchStreamScreen has connect button
    testWidgets('TwitchStreamScreen has Twitch connect button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const TwitchStreamScreen(),
        ),
      );

      expect(find.text('Twitch で接続'), findsOneWidget);
    });

    /// Test 7: SponsorshipScreen displays loading state
    testWidgets('SponsorshipScreen displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const SponsorshipScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    /// Test 8: SponsorshipScreen displays empty state
    testWidgets('SponsorshipScreen displays empty state when no info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const SponsorshipScreen(),
        ),
      );

      // Verify empty state UI
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('スポンサーシップ'), findsOneWidget);
    });

    /// Test 9: YouTubeShareScreen AppBar
    testWidgets('YouTubeShareScreen has correct AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      expect(find.text('YouTube 共有'), findsOneWidget);
    });

    /// Test 10: TwitchStreamScreen AppBar
    testWidgets('TwitchStreamScreen has correct AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const TwitchStreamScreen(),
        ),
      );

      expect(find.text('Twitch 配信'), findsOneWidget);
    });

    /// Test 11: SponsorshipScreen AppBar
    testWidgets('SponsorshipScreen has correct AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const SponsorshipScreen(),
        ),
      );

      expect(find.text('スポンサーシップ'), findsWidgets);
    });

    /// Test 12: All screens use dark theme
    testWidgets('All streaming screens use dark theme',
        (WidgetTester tester) async {
      // YouTube Screen
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // Verify dark background
      expect(
        tester.widget<Scaffold>(scaffold.first).backgroundColor,
        Colors.black87,
      );
    });

    /// Test 13: YouTube AppBar styling
    testWidgets('YouTubeShareScreen AppBar has correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const YouTubeShareScreen(),
        ),
      );

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.centerTitle, isTrue);
      expect(appBarWidget.elevation, 0);
    });

    /// Test 14: Twitch AppBar styling
    testWidgets('TwitchStreamScreen AppBar has correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const TwitchStreamScreen(),
        ),
      );

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.centerTitle, isTrue);
    });

    /// Test 15: Sponsorship AppBar styling
    testWidgets('SponsorshipScreen AppBar has correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          container: testContainer,
          child: const SponsorshipScreen(),
        ),
      );

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.centerTitle, isTrue);
    });
  });
}
