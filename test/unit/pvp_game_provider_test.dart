import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/viewmodels/friend_provider.dart' as friend_provider;

void main() {
  group('createTournamentGameProvider spectator session wiring', () {
    late FakeFirebaseFirestore firestore;
    late ProviderContainer container;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      container = ProviderContainer(overrides: [
        pvpGameServiceProvider.overrideWithValue(PvpGameService(firestore)),
        spectatorServiceProvider.overrideWithValue(SpectatorService(firestore)),
        // friend_activity_provider.dart watches friend_provider.dart's
        // friendServiceProvider specifically, not the one re-exported from
        // viewmodels/index.dart (that barrel resolves the name to
        // social_features_provider.dart's implementation instead - a
        // pre-existing, documented duplicate-name split in this codebase).
        friend_provider.friendServiceProvider
            .overrideWithValue(FriendService(firestore: firestore)),
      ]);
    });

    tearDown(() => container.dispose());

    /// In production the match doc always exists before a player can tap
    /// "対局を開始する" for it (TournamentService writes every round's
    /// match docs up front), which createGameForTournamentMatch's
    /// idempotency relies on - mirrors the same setup already used in
    /// pvp_game_service_test.dart.
    Future<void> seedMatch(String tournamentId, String matchId) {
      return firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .doc(matchId)
          .set({'gameId': null, 'status': 'pending'});
    }

    test('starts a spectator session hosted by the caller when the caller is black', () async {
      await seedMatch('t1', 'm1');
      final gameId = await container.read(createTournamentGameProvider)(
        't1', 'm1', 19, 'black-uid', 'Black', 'white-uid', 'White', 'black-uid',
      );
      await pumpEventQueue();

      final game = await PvpGameService(firestore).getGame(gameId);
      expect(game!.spectatorSessionId, isNotNull);

      final sessions = await SpectatorService(firestore).getGameSpectatorSessions(gameId);
      expect(sessions, hasLength(1));
      expect(sessions.single.hostUid, 'black-uid');
      expect(sessions.single.coHostUid, 'white-uid');
      expect(sessions.single.gameType, 'pvp_game');
    });

    test('starts a spectator session hosted by the caller when the caller is white', () async {
      // Reproduces the bug this fix closes: the tournament bracket fixes
      // black/white by uid ordering, so the player who taps "start" is not
      // always black - the spectator session's hostUid (which Firestore
      // rules require to equal request.auth.uid) must follow the caller,
      // not blindly follow blackUid.
      await seedMatch('t1', 'm1');
      final gameId = await container.read(createTournamentGameProvider)(
        't1', 'm1', 19, 'black-uid', 'Black', 'white-uid', 'White', 'white-uid',
      );
      await pumpEventQueue();

      final sessions = await SpectatorService(firestore).getGameSpectatorSessions(gameId);
      expect(sessions, hasLength(1));
      expect(sessions.single.hostUid, 'white-uid');
      expect(sessions.single.coHostUid, 'black-uid');
    });

    test('does not create a second spectator session when the other participant '
        'also calls it for the same match', () async {
      await seedMatch('t1', 'm1');
      final firstGameId = await container.read(createTournamentGameProvider)(
        't1', 'm1', 19, 'black-uid', 'Black', 'white-uid', 'White', 'black-uid',
      );
      await pumpEventQueue();

      final secondGameId = await container.read(createTournamentGameProvider)(
        't1', 'm1', 19, 'black-uid', 'Black', 'white-uid', 'White', 'white-uid',
      );
      await pumpEventQueue();

      expect(secondGameId, firstGameId);
      final sessions = await SpectatorService(firestore).getGameSpectatorSessions(firstGameId);
      expect(sessions, hasLength(1));
      // The first caller (black) won the transaction, so the session stays
      // hosted by them - the second (white) call must not overwrite it.
      expect(sessions.single.hostUid, 'black-uid');
    });
  });
}
