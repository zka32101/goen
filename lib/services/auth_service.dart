import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';

/// Service for Firebase Authentication
/// Handles user signup, signin, signout, and session management
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// Get current user stream (reactive)
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        _logger.i('User signed out');
        return null;
      }

      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        subscriptionActive: false, // TBD: fetch from Firestore
        subscriptionStartDate: DateTime.now(), // TBD: fetch from Firestore
        tutorialCompleted: false, // TBD: fetch from Firestore
        gamesPlayedCount: 0, // TBD: fetch from Firestore
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  /// Get current user (one-time, synchronous)
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      subscriptionActive: false,
      subscriptionStartDate: DateTime.now(),
      tutorialCompleted: false,
      gamesPlayedCount: 0,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Sign up with email and password
  ///
  /// Parameters:
  /// - email: User email address
  /// - password: User password (min 6 chars)
  ///
  /// Throws: FirebaseAuthException on error
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    assert(email.isNotEmpty, 'Email cannot be empty');
    assert(password.length >= 6, 'Password must be at least 6 characters');

    try {
      _logger.i('Signing up user: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      _logger.i('✅ User signed up: ${firebaseUser.uid}');

      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: null,
        subscriptionActive: false,
        subscriptionStartDate: DateTime.now(),
        tutorialCompleted: false,
        gamesPlayedCount: 0,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error during signup: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error during signup: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  ///
  /// Parameters:
  /// - email: User email address
  /// - password: User password
  ///
  /// Throws: FirebaseAuthException on error
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    assert(email.isNotEmpty, 'Email cannot be empty');
    assert(password.isNotEmpty, 'Password cannot be empty');

    try {
      _logger.i('Signing in user: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      _logger.i('✅ User signed in: ${firebaseUser.uid}');

      return User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        subscriptionActive: false, // TBD: fetch from Firestore
        subscriptionStartDate: DateTime.now(),
        tutorialCompleted: false, // TBD: fetch from Firestore
        gamesPlayedCount: 0, // TBD: fetch from Firestore
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error during signin: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error during signin: $e');
      rethrow;
    }
  }

  /// Sign in anonymously (for guest play)
  ///
  /// Useful for allowing players to try the game before creating account
  Future<User> signInAnonymously() async {
    try {
      _logger.i('Signing in anonymously');

      final userCredential = await _auth.signInAnonymously();
      final firebaseUser = userCredential.user!;

      _logger.i('✅ Anonymous user signed in: ${firebaseUser.uid}');

      return User(
        uid: firebaseUser.uid,
        email: 'anonymous@goen.local',
        displayName: 'Guest Player',
        subscriptionActive: false,
        subscriptionStartDate: DateTime.now(),
        tutorialCompleted: false,
        gamesPlayedCount: 0,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error during anonymous signin: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error during anonymous signin: $e');
      rethrow;
    }
  }

  /// Link anonymous account to email/password
  ///
  /// Call after user decides to create persistent account
  Future<void> linkAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    assert(email.isNotEmpty, 'Email cannot be empty');
    assert(password.length >= 6, 'Password must be at least 6 characters');

    try {
      final user = _auth.currentUser;
      if (user == null || !user.isAnonymous) {
        throw AuthServiceException('No anonymous user to link');
      }

      _logger.i('Linking anonymous account to email: $email');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      _logger.i('✅ Account linked successfully');
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error during link: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error during link: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _logger.i('Signing out');
      await _auth.signOut();
      _logger.i('✅ User signed out');
    } catch (e) {
      _logger.e('Error during signout: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    assert(email.isNotEmpty, 'Email cannot be empty');

    try {
      _logger.i('Sending password reset email: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error sending reset email: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error sending reset email: $e');
      rethrow;
    }
  }

  /// Update user profile display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthServiceException('No user logged in');
      }

      _logger.i('Updating display name: $displayName');
      await user.updateDisplayName(displayName);
      _logger.i('✅ Display name updated');
    } catch (e) {
      _logger.e('Error updating display name: $e');
      rethrow;
    }
  }

  /// Delete user account (caution: irreversible)
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthServiceException('No user logged in');
      }

      _logger.w('Deleting user account: ${user.uid}');
      await user.delete();
      _logger.i('✅ Account deleted');
    } on FirebaseAuthException catch (e) {
      _logger.e('Auth error deleting account: ${e.code}');
      throw AuthServiceException(_parseAuthError(e));
    } catch (e) {
      _logger.e('Unexpected error deleting account: $e');
      rethrow;
    }
  }

  /// Get Firebase auth token (for debugging)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      return await user.getIdToken(forceRefresh);
    } catch (e) {
      _logger.e('Error getting ID token: $e');
      rethrow;
    }
  }

  /// Parse Firebase auth error into user-friendly message
  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'user-not-found':
        return 'User not found. Check your email.';
      case 'wrong-password':
        return 'Password is incorrect.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

/// Custom exception for Auth errors
class AuthServiceException implements Exception {
  final String message;

  AuthServiceException(this.message);

  @override
  String toString() => 'AuthServiceException: $message';
}
