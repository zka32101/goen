import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';

final _logger = Logger();

// ================== KIFU LIBRARY ==================

/// Singleton instance of FirestoreService (shared)
final kifuFirestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Kifu library - all available games to study
final kifuLibraryProvider = FutureProvider<List<KifuLibrary>>((ref) async {
  _logger.i('Fetching kifu library');

  final firestoreService = ref.watch(kifuFirestoreProvider);
  try {
    final games = await firestoreService.getCopyrightFreeKifus();
    _logger.i('✅ Kifu library fetched: ${games.length} games');
    return games;
  } catch (e) {
    _logger.e('❌ Failed to fetch kifu library: $e');
    return []; // Return empty list on error
  }
});

/// Kifu library filtered by difficulty
final kifuByDifficultyProvider = FutureProvider.family<List<KifuLibrary>, int>(
  (ref, difficulty) async {
    _logger.i('Fetching kifu by difficulty: $difficulty');

    final library = await ref.watch(kifuLibraryProvider.future);
    return library;
    // TODO: Implement difficulty filtering
  },
);

/// Currently selected kifu game
final selectedKifuProvider = StateProvider<KifuLibrary?>((ref) {
  return null;
});

/// Observation progress tracking
final kifuObservationProgressProvider = StateProvider<Map<String, int>>((ref) {
  return {}; // game_id -> move_number
});
