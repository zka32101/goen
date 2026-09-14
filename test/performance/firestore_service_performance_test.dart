import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:goen/services/firestore_service.dart';
import 'package:goen/models/index.dart';
import 'performance_utils.dart';

// Mock Firestore service for performance testing
class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('FirestoreService Performance Tests', () {
    late FirestoreService service;

    setUp(() {
      service = MockFirestoreService();
    });

    /// Helper to create a mock GameRecord
    GameRecord _createMockGameRecord({
      required String id,
      int moveCount = 50,
    }) {
      return GameRecord(
        id: id,
        uid: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        boardSize: 9,
        sgfData: _generateSgf(moveCount),
        result: 'win',
        aiLevel: 5,
        playedAt: DateTime.now(),
        duration: Duration(minutes: 15),
        playerScore: 125.5,
        aiScore: 120.0,
        analyzedAt: null,
        analysis: null,
      );
    }

    /// Generate SGF string for testing
    String _generateSgf(int moves) {
      final buffer = StringBuffer();
      buffer.write('(;GM[1]SZ[9]');
      for (int i = 0; i < moves; i++) {
        final row = i % 9;
        final col = (i ~/ 9) % 9;
        final color = i % 2 == 0 ? 'B' : 'W';
        buffer.write(';$color[${_numToLetter(col)},${_numToLetter(row)}]');
      }
      buffer.write(')');
      return buffer.toString();
    }

    String _numToLetter(int num) =>
        String.fromCharCode(97 + num); // a-i for 9x9

    test('📊 GameRecord serialization performance', () {
      final record = _createMockGameRecord(id: 'game-1', moveCount: 100);

      final measurement = PerformanceHelper.measureSync(
        () => record.toJson(),
        label: 'GameRecord serialization',
      );

      PerformanceHelper.expectWithinThreshold(
        measurement.milliseconds,
        PerformanceThresholds.serialization,
        operationName: 'GameRecord serialization',
      );

      expect(measurement.result, isNotNull);
      expect(measurement.result, containsPair('id', 'game-1'));
    });

    test('📊 GameRecord deserialization performance', () {
      final record = _createMockGameRecord(id: 'game-1', moveCount: 100);
      final json = record.toJson();

      final stats = await PerformanceHelper.measureMultiple(
        () => Future.value(GameRecord.fromJson(json)),
        iterations: 100,
        label: 'GameRecord deserialization (100 iterations)',
      );

      expect(stats.averageWithinThreshold(PerformanceThresholds.serialization), true);
    });

    test('📊 User model serialization is efficient', () {
      final user = User(
        uid: 'test-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
        subscriptionActive: true,
        tutorialCompleted: true,
        preferredBoardSize: 9,
        defaultAiDifficulty: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const iterations = 500;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => user.toJson(),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(
        averageMs,
        lessThan(1.0),
        reason: 'User serialization average should be sub-millisecond',
      );
    });

    test('📊 Multiple game records batch serialization', () async {
      final games = List.generate(
        10,
        (i) => _createMockGameRecord(
          id: 'game-$i',
          moveCount: 50 + (i * 5),
        ),
      );

      final measurement = PerformanceHelper.measureSync(
        () => games.map((g) => g.toJson()).toList(),
        label: 'Batch serialization (10 games)',
      );

      PerformanceHelper.expectWithinThreshold(
        measurement.milliseconds,
        PerformanceThresholds.serialization * 2, // Allow 2x for batch
        operationName: 'Batch game serialization',
      );

      expect(measurement.result.length, equals(10));
    });

    test('📊 TsumeGoProblem serialization', () {
      final problem = TsumeGoProblem(
        id: 'problem-1',
        difficulty: 3,
        sgfData: _generateSgf(30),
        solutionSgf: _generateSgf(5),
        explanation: 'This is a test problem explanation that teaches the concept of territory and influence.',
        source: 'Test Collection',
        createdAt: DateTime.now(),
        category: 'fundamentals',
      );

      const iterations = 200;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => problem.toJson(),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(2.0));
    });

    test('📊 KifuLibrary game serialization', () {
      final kifu = KifuLibrary(
        id: 'kifu-1',
        title: 'Historical Game: Honinbo Shusaku vs Iwasaki Kisaburo',
        players: 'Honinbo Shusaku vs Iwasaki Kisaburo',
        sgfData: _generateSgf(200), // Long game
        aiCommentaryData: 'Professional level strategy demonstration...',
        category: 'professional',
        source: 'Go Server Archive',
        createdAt: DateTime.now(),
      );

      const iterations = 100;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => kifu.toJson(),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(
        averageMs,
        lessThan(3.0),
        reason: 'Long SGF serialization should still be fast',
      );
    });

    test('📊 Data validation performance', () {
      // Email validation
      const validEmails = [
        'user@example.com',
        'test.user@domain.co.uk',
        'premium+user@service.org',
      ];

      var totalTime = 0;
      for (final email in validEmails) {
        final measurement = PerformanceHelper.measureSync(
          () => email.contains('@') && email.contains('.'),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / validEmails.length;
      expect(averageMs, lessThan(1.0));
    });

    test('📊 Collection query result parsing', () {
      // Simulate parsing multiple game records from Firestore
      final gameJsons = List.generate(
        50,
        (i) => _createMockGameRecord(id: 'game-$i').toJson(),
      );

      final measurement = PerformanceHelper.measureSync(
        () => gameJsons
            .map((json) => GameRecord.fromJson(json))
            .toList(),
        label: 'Parse 50 game records from query',
      );

      expect(
        measurement.milliseconds,
        lessThanOrEqualTo(PerformanceThresholds.serialization * 3),
      );
    });

    test('🔄 Nested model serialization', () {
      // Test complex nested structures
      final user = User(
        uid: 'uid-1',
        email: 'user@test.com',
        displayName: 'Test User',
        photoUrl: null,
        subscriptionActive: true,
        tutorialCompleted: true,
        preferredBoardSize: 13,
        defaultAiDifficulty: 7,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      const iterations = 200;
      final profile = PerformanceProfile('Nested Serialization');

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => user.toJson(),
        );

        if (i == 0) {
          profile.record('First serialization', measurement.milliseconds);
        } else if (i == iterations ~/ 2) {
          profile.record('Mid serialization', measurement.milliseconds);
        } else if (i == iterations - 1) {
          profile.record('Last serialization', measurement.milliseconds);
        }
      }

      profile.printReport();
    });

    test('💾 Large SGF data handling', () {
      // Test with very long game (350+ moves)
      final largeSgf = _generateSgf(350);

      final measurement = PerformanceHelper.measureSync(
        () => largeSgf.length, // Measure string length calculation
        label: 'Large SGF property access',
      );

      expect(measurement.milliseconds, lessThanOrEqualTo(1));
      expect(measurement.result, greaterThan(2000)); // Should be substantial data
    });

    test('💾 GameRecord with large commentary', () {
      final record = GameRecord(
        id: 'game-commentary',
        uid: 'uid-1',
        boardSize: 19,
        sgfData: _generateSgf(300),
        result: 'draw',
        aiLevel: 8,
        playedAt: DateTime.now(),
        duration: Duration(hours: 1, minutes: 30),
        playerScore: 150.5,
        aiScore: 150.0,
        analyzedAt: DateTime.now(),
        analysis: 'Comprehensive analysis of this 300-move professional game. '
            'The opening was solid, the midgame showed good fighting spirit, '
            'and the endgame was precisely executed. Key moments included... ' *
            10, // Repeat to make it substantial
      );

      final measurement = PerformanceHelper.measureSync(
        () => record.toJson(),
        label: 'GameRecord with extensive analysis',
      );

      expect(
        measurement.milliseconds,
        lessThanOrEqualTo(PerformanceThresholds.serialization * 2),
      );
    });

    test('🔄 Concurrent model operations', () async {
      final records = List.generate(
        10,
        (i) => _createMockGameRecord(id: 'game-$i'),
      );

      final measurement = PerformanceHelper.measureSync(
        () {
          // Simulate concurrent-like operations
          return records
              .map((r) => r.toJson())
              .toList()
              .map((json) => GameRecord.fromJson(json))
              .toList();
        },
        label: 'Sequential serialize-deserialize cycle (10 records)',
      );

      expect(
        measurement.milliseconds,
        lessThanOrEqualTo(PerformanceThresholds.serialization * 5),
      );
    });
  });
}
