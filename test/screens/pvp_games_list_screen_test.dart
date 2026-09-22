import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/models/index.dart';
import 'package:goen/views/screens/pvp_games_list_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';

PvpGame _buildGame({
  required String id,
  required bool isBlackTurn,
  int movesCount = 4,
}) {
  return PvpGame(
    id: id,
    boardSize: 9,
    blackUid: TestData.testUser.uid,
    blackDisplayName: TestData.testUser.displayName!,
    whiteUid: 'opponent-uid',
    whiteDisplayName: 'Opponent Player',
    stones: List.generate(9, (_) => List.filled(9, 0)),
    isBlackTurn: isBlackTurn,
    capturedBlack: 0,
    capturedWhite: 0,
    movesCount: movesCount,
    consecutivePasses: 0,
    status: 'active',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('PvpGamesListScreen', () {
    testWidgets('shows the empty state when there are no active games',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(TestData.testUser),
          userActivePvpGamesProvider(TestData.testUser.uid)
              .overrideWith((ref) async => <PvpGame>[]),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PvpGamesListScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('進行中のPvP対局はありません'), findsOneWidget);
    });

    testWidgets('lists active games and shows whose turn it is',
        (WidgetTester tester) async {
      final games = [
        _buildGame(id: 'game-1', isBlackTurn: true),
        _buildGame(id: 'game-2', isBlackTurn: false),
      ];
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(TestData.testUser),
          userActivePvpGamesProvider(TestData.testUser.uid)
              .overrideWith((ref) async => games),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PvpGamesListScreen()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('vs Opponent Player'), findsNWidgets(2));
      expect(find.text('あなたの番'), findsOneWidget);
      expect(find.text('相手の番'), findsOneWidget);
    });
  });
}
