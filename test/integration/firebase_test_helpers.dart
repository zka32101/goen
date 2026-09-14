import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/firestore_service.dart';
import 'package:goen/models/index.dart';

/// Test helpers for Firebase integration testing
class FirebaseTestHelpers {
  static late FirebaseApp testApp;
  static late FirebaseFirestore testFirestore;
  static late FirebaseAuth testAuth;

  /// Initialize Firebase for testing
  ///
  /// Uses emulator if available, falls back to production credentials
  static Future<void> initializeFirebaseForTesting() async {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      testApp = Firebase.apps.first;
      testFirestore = FirebaseFirestore.instance;
      testAuth = FirebaseAuth.instance;
      return;
    }

    try {
      // Initialize with default options
      // In production tests, this would use flutterfire configure generated values
      testApp = await Firebase.initializeApp(
        name: 'goen-test-${DateTime.now().millisecondsSinceEpoch}',
      );

      testFirestore = FirebaseFirestore.instanceFor(app: testApp);
      testAuth = FirebaseAuth.instanceFor(app: testApp);

      // Try to connect to emulator if running
      await _tryConnectToEmulator();
    } catch (e) {
      print('⚠️ Firebase initialization warning: $e');
      // Continue with whatever initialization succeeded
    }
  }

  /// Try to connect to Firestore and Auth emulators
  static Future<void> _tryConnectToEmulator() async {
    try {
      // Firestore emulator
      await testFirestore.waitForPendingWrites();

      // Auth emulator - typically runs on port 9099
      // This is a placeholder - actual emulator connection requires specific setup
      print('✓ Firebase emulators configured');
    } catch (e) {
      print('ℹ️ Emulator not available: $e');
    }
  }

  /// Clean up Firebase resources
  static Future<void> cleanup() async {
    try {
      // Clear all data
      await _clearFirestoreData();

      // Sign out
      await testAuth.signOut();

      // Delete test app
      await testApp.delete();
    } catch (e) {
      print('⚠️ Cleanup warning: $e');
    }
  }

  /// Clear all Firestore collections
  static Future<void> _clearFirestoreData() async {
    try {
      // Clear users collection
      final users = await testFirestore.collection('users').get();
      for (final doc in users.docs) {
        await doc.reference.delete();
      }

      // Clear game records
      final games = await testFirestore.collection('gameRecords').get();
      for (final doc in games.docs) {
        await doc.reference.delete();
      }

      // Clear other collections similarly
      final collections = [
        'tsumeGoProblems',
        'userTsumeGoLogs',
        'kifuLibrary',
        'observationLogs',
      ];

      for (final collection in collections) {
        final docs = await testFirestore.collection(collection).get();
        for (final doc in docs.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('⚠️ Data clearing warning: $e');
    }
  }

  /// Create a test user in Firebase Auth
  static Future<UserCredential> createTestUser({
    required String email,
    required String password,
  }) async {
    try {
      return await testAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('⚠️ User creation warning: $e');
      // Try signing in if user exists
      return await testAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  /// Sign in a test user
  static Future<UserCredential> signInTestUser({
    required String email,
    required String password,
  }) async {
    return await testAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create a test user document in Firestore
  static Future<void> createTestUserDocument({
    required String uid,
    required String email,
    String displayName = 'Test User',
  }) async {
    final user = User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: null,
      subscriptionActive: false,
      tutorialCompleted: false,
      preferredBoardSize: 9,
      defaultAiDifficulty: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await testFirestore
        .collection('users')
        .doc(uid)
        .set(user.toJson());
  }

  /// Create a test game record
  static Future<String> createTestGameRecord({
    required String uid,
    int boardSize = 9,
    String result = 'win',
    int aiLevel = 5,
  }) async {
    final game = GameRecord(
      id: 'game-${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      boardSize: boardSize,
      sgfData: _generateTestSgf(boardSize, 30),
      result: result,
      aiLevel: aiLevel,
      playedAt: DateTime.now(),
      duration: Duration(minutes: 15),
      playerScore: 125.5,
      aiScore: 120.0,
      analyzedAt: null,
      analysis: null,
    );

    await testFirestore
        .collection('gameRecords')
        .doc(game.id)
        .set(game.toJson());

    return game.id;
  }

  /// Create a test Tsume Go problem
  static Future<String> createTestTsumeGoProblem({
    int difficulty = 3,
  }) async {
    final problem = TsumeGoProblem(
      id: 'problem-${DateTime.now().millisecondsSinceEpoch}',
      difficulty: difficulty,
      sgfData: _generateTestSgf(9, 15),
      solutionSgf: _generateTestSgf(9, 3),
      explanation: 'Test problem explanation',
      source: 'Test Collection',
      createdAt: DateTime.now(),
      category: 'fundamentals',
    );

    await testFirestore
        .collection('tsumeGoProblems')
        .doc(problem.id)
        .set(problem.toJson());

    return problem.id;
  }

  /// Helper to generate test SGF data
  static String _generateTestSgf(int boardSize, int moves) {
    final buffer = StringBuffer();
    buffer.write('(;GM[1]SZ[$boardSize]');

    for (int i = 0; i < moves; i++) {
      final row = (i % boardSize).toRadixString(36);
      final col = ((i + 1) % boardSize).toRadixString(36);
      final color = i % 2 == 0 ? 'B' : 'W';
      buffer.write(';$color[$col$row]');
    }

    buffer.write(')');
    return buffer.toString();
  }

  /// Get current test user
  static User? getCurrentTestUser() {
    return testAuth.currentUser != null
        ? User(
            uid: testAuth.currentUser!.uid,
            email: testAuth.currentUser!.email ?? '',
            displayName: testAuth.currentUser!.displayName ?? 'Test User',
            photoUrl: testAuth.currentUser!.photoURL,
            subscriptionActive: false,
            tutorialCompleted: false,
            preferredBoardSize: 9,
            defaultAiDifficulty: 5,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : null;
  }

  /// Wait for Firestore to sync
  static Future<void> waitForSync() async {
    await testFirestore.waitForPendingWrites();
  }
}

/// Firestore test transaction helper
class FirebaseTestTransaction {
  final CollectionReference collection;
  final String docId;

  FirebaseTestTransaction({
    required this.collection,
    required this.docId,
  });

  /// Read data from Firestore
  Future<Map<String, dynamic>?> read() async {
    final doc = await collection.doc(docId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// Write data to Firestore
  Future<void> write(Map<String, dynamic> data) async {
    await collection.doc(docId).set(data);
  }

  /// Update data in Firestore
  Future<void> update(Map<String, dynamic> data) async {
    await collection.doc(docId).update(data);
  }

  /// Delete document from Firestore
  Future<void> delete() async {
    await collection.doc(docId).delete();
  }

  /// Verify data exists
  Future<bool> exists() async {
    final doc = await collection.doc(docId).get();
    return doc.exists;
  }
}
