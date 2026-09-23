import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';

final _logger = Logger();

/// トーナメント管理サービス
class TournamentService {
  final FirebaseFirestore _firestore;

  TournamentService([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String tournamentsCollection = 'tournaments';
  static const String participantsCollection = 'participants';
  static const String matchesCollection = 'matches';

  /// 単一のトーナメントを取得する
  Future<Tournament?> getTournament(String tournamentId) async {
    try {
      final doc = await _firestore.collection(tournamentsCollection).doc(tournamentId).get();
      if (!doc.exists) return null;
      return Tournament.fromFirestore(doc);
    } catch (e) {
      _logger.e('Error fetching tournament: $e');
      rethrow;
    }
  }

  /// トーナメント作成
  Future<Tournament?> createTournament({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required String format,
    required String createdByUid,
    int boardSize = 19,
  }) async {
    try {
      _logger.i('Creating tournament: $name');

      final docRef = _firestore.collection(tournamentsCollection).doc();
      final tournament = Tournament(
        id: docRef.id,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        format: format,
        status: 'upcoming',
        participantUids: [],
        createdBy: createdByUid,
        boardSize: boardSize,
        createdAt: DateTime.now(),
      );

      await docRef.set(tournament.toFirestore());
      _logger.i('✅ Tournament created: ${docRef.id}');
      return tournament;
    } catch (e) {
      _logger.e('Error creating tournament: $e');
      rethrow;
    }
  }

  /// トーナメントに参加
  Future<bool> joinTournament({
    required String tournamentId,
    required String uid,
    required String displayName,
  }) async {
    try {
      _logger.i('Joining tournament: $tournamentId');

      final tournamentRef =
          _firestore.collection(tournamentsCollection).doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();

      if (!tournamentDoc.exists) {
        throw Exception('Tournament not found');
      }

      final tournament = Tournament.fromFirestore(
          tournamentDoc as DocumentSnapshot<Map<String, dynamic>>);

      if (tournament.isFull) {
        throw Exception('Tournament is full');
      }

      // Add participant
      await tournamentRef.collection(participantsCollection).doc(uid).set({
        'tournamentId': tournamentId,
        'displayName': displayName,
        'seed': tournament.participantUids.length + 1,
        'currentRound': 1,
        'joinedAt': Timestamp.now(),
      });

      // Update participant list in tournament
      await tournamentRef.update({
        'participantUids': FieldValue.arrayUnion([uid]),
      });

      _logger.i('✅ User joined tournament');
      return true;
    } catch (e) {
      _logger.e('Error joining tournament: $e');
      rethrow;
    }
  }

  /// トーナメントを開始する。参加者が2人未満なら例外。
  /// - single_elimination: 1回戦のブラケットを生成（不戦勝は即2回戦へ）。
  /// - round_robin: サークル法で全節の対戦カードを一度に生成する。参加者が
  ///   奇数なら各節1人が順番に不戦休みになる（不戦休みの節には試合ドキュ
  ///   メント自体を作らない）。優勝は全試合終了時点の勝ち数最多者（同数は
  ///   uid昇順の簡易タイブレーク — 対戦成績・得失点差などの本格的な
  ///   タイブレークは未実装、既知の制約）。
  /// - swiss: 未対応（ペアリングアルゴリズムが未実装）。
  Future<void> startTournament(String tournamentId) async {
    try {
      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();
      if (!tournamentDoc.exists) throw Exception('Tournament not found');

      final tournament = Tournament.fromFirestore(
          tournamentDoc as DocumentSnapshot<Map<String, dynamic>>);
      if (tournament.format != 'single_elimination' && tournament.format != 'round_robin') {
        throw Exception('${tournament.format} is not yet supported for automatic bracket generation');
      }
      if (tournament.participantUids.length < 2) {
        throw Exception('Not enough participants to start');
      }

      final participantsSnapshot =
          await tournamentRef.collection(participantsCollection).get();
      final displayNames = <String, String>{
        for (final doc in participantsSnapshot.docs)
          doc.id: (doc.data()['displayName'] as String?) ?? 'Player',
      };

      if (tournament.format == 'round_robin') {
        await _generateRoundRobinSchedule(
          tournamentId: tournamentId,
          playerUids: List<String>.from(tournament.participantUids),
          displayNames: displayNames,
        );
        await tournamentRef.update({'status': 'active'});
        _logger.i('✅ Tournament started with full round-robin schedule: $tournamentId');
        return;
      }

      await _generateRound(
        tournamentId: tournamentId,
        round: 1,
        playerUids: List<String>.from(tournament.participantUids),
        displayNames: displayNames,
      );

      await tournamentRef.update({'status': 'active'});
      // 稀なケース（全員不戦勝で1ラウンド目が即完了）でも進行が止まらないようにする。
      await _advanceRoundIfComplete(tournamentId: tournamentId, round: 1);
      _logger.i('✅ Tournament started with round 1 bracket: $tournamentId');
    } catch (e) {
      _logger.e('Error starting tournament: $e');
      rethrow;
    }
  }

  /// サークル法で総当たり戦の全節を一度に生成する。参加者が奇数なら
  /// ダミーの空き枠を1つ加え、その枠と当たった人がその節は不戦休みになる
  /// （不戦休みには試合ドキュメントを作らない — エリミネーションの不戦勝
  /// とは異なり、総当たりの不戦休みは自動勝利ではないため）。
  ///
  /// 全対戦カード(n人でn*(n-1)/2試合)を1つのWriteBatchで書き込む。
  /// Firestoreのバッチ上限は500操作なので、TournamentCreateScreenの
  /// 最大参加人数(32人→496試合)までは安全だが、上限を引き上げる場合は
  /// バッチ分割が必要になる。
  Future<void> _generateRoundRobinSchedule({
    required String tournamentId,
    required List<String> playerUids,
    required Map<String, String> displayNames,
  }) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
    final schedule = _roundRobinPairings(playerUids);
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (var i = 0; i < schedule.length; i++) {
      final round = i + 1;
      for (final pair in schedule[i]) {
        final matchRef = tournamentRef.collection(matchesCollection).doc();
        final match = TournamentMatch(
          id: matchRef.id,
          tournamentId: tournamentId,
          player1Uid: pair.$1,
          player1DisplayName: displayNames[pair.$1],
          player2Uid: pair.$2,
          player2DisplayName: displayNames[pair.$2],
          round: round,
          status: 'pending',
          scheduledAt: now,
        );
        batch.set(matchRef, match.toFirestore());
      }
    }

    await batch.commit();
    _logger.i('Generated round-robin schedule (${schedule.length} rounds) for $tournamentId');
  }

  /// 総当たり戦の対戦カードをサークル法で組む。先頭を固定し、残りを1つずつ
  /// 回転させることで、全員が互いに一度ずつ当たる組み合わせを作る。
  /// 参加者が奇数の場合はnullの空き枠を1つ加え（その節はその相手が不戦休み）、
  /// 偶数ならn-1節、奇数ならn節になる。
  List<List<(String, String)>> _roundRobinPairings(List<String> playerUids) {
    final players = List<String?>.from(playerUids);
    if (players.length.isOdd) players.add(null);
    final n = players.length;
    final rounds = <List<(String, String)>>[];

    for (var r = 0; r < n - 1; r++) {
      final roundPairs = <(String, String)>[];
      for (var i = 0; i < n ~/ 2; i++) {
        final a = players[i];
        final b = players[n - 1 - i];
        if (a != null && b != null) roundPairs.add((a, b));
      }
      rounds.add(roundPairs);
      final last = players.removeLast();
      players.insert(1, last);
    }
    return rounds;
  }

  /// プレイヤーのリストからペアを作り、指定ラウンドの試合を生成する。
  /// 奇数なら最後の1人を不戦勝として即座に勝者確定させる。
  Future<void> _generateRound({
    required String tournamentId,
    required int round,
    required List<String> playerUids,
    required Map<String, String> displayNames,
  }) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (var i = 0; i < playerUids.length; i += 2) {
      final player1Uid = playerUids[i];
      final hasOpponent = i + 1 < playerUids.length;
      final player2Uid = hasOpponent ? playerUids[i + 1] : null;

      final matchRef = tournamentRef.collection(matchesCollection).doc();
      final match = TournamentMatch(
        id: matchRef.id,
        tournamentId: tournamentId,
        player1Uid: player1Uid,
        player1DisplayName: displayNames[player1Uid],
        player2Uid: player2Uid,
        player2DisplayName: player2Uid != null ? displayNames[player2Uid] : null,
        round: round,
        // 不戦勝は即座に完了扱いにする。
        winnerUid: hasOpponent ? null : player1Uid,
        status: hasOpponent ? 'pending' : 'completed',
        scheduledAt: now,
        completedAt: hasOpponent ? null : now,
      );
      batch.set(matchRef, match.toFirestore());
    }

    await batch.commit();
    _logger.i('Generated round $round with ${(playerUids.length / 2).ceil()} matches for $tournamentId');
  }

  /// 対局が紐づく試合に勝者を紐付ける。実際のPvpGame作成はプロバイダー層が行う。
  Future<void> attachGameToMatch({
    required String tournamentId,
    required String matchId,
    required String gameId,
  }) async {
    try {
      await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentId)
          .collection(matchesCollection)
          .doc(matchId)
          .update({'gameId': gameId, 'status': 'in_progress'});
    } catch (e) {
      _logger.e('Error attaching game to tournament match: $e');
      rethrow;
    }
  }

  /// トーナメント試合取得
  Future<List<TournamentMatch>> getTournamentMatches({
    required String tournamentId,
    int? round,
  }) async {
    try {
      _logger.i('Fetching matches for tournament: $tournamentId');

      var query = _firestore
          .collection(tournamentsCollection)
          .doc(tournamentId)
          .collection(matchesCollection)
          .orderBy('round')
          .orderBy('scheduledAt');

      if (round != null) {
        query = query.where('round', isEqualTo: round);
      }

      final snapshot = await query.get();
      final matches = snapshot.docs
          .map((doc) => TournamentMatch.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Matches fetched: ${matches.length}');
      return matches;
    } catch (e) {
      _logger.e('Error fetching matches: $e');
      rethrow;
    }
  }

  /// 試合結果を記録する。
  /// - single_elimination: そのラウンドの全試合が完了していれば勝者同士で
  ///   次ラウンドを自動生成し、決勝が完了していればトーナメントを完了にする。
  /// - round_robin: 全節の全試合が完了していれば、勝ち数最多者を優勝として
  ///   トーナメントを完了にする（全対戦カードは開始時に一度に生成済みなので
  ///   ラウンド自動生成は不要）。
  Future<void> recordMatchResult({
    required String tournamentId,
    required String matchId,
    required String winnerUid,
  }) async {
    try {
      _logger.i('Recording match result: $matchId');

      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final matchRef = tournamentRef.collection(matchesCollection).doc(matchId);
      final matchDoc = await matchRef.get();
      if (!matchDoc.exists) throw Exception('Match not found: $matchId');
      final round = (matchDoc.data()?['round'] as int?) ?? 1;

      await matchRef.update({
        'winnerUid': winnerUid,
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
      _logger.i('✅ Match result recorded');

      final tournamentDoc = await tournamentRef.get();
      final format = (tournamentDoc.data()?['format'] as String?) ?? 'single_elimination';
      if (format == 'round_robin') {
        await _completeRoundRobinIfDone(tournamentId: tournamentId);
      } else {
        await _advanceRoundIfComplete(tournamentId: tournamentId, round: round);
      }
    } catch (e) {
      _logger.e('Error recording match result: $e');
      rethrow;
    }
  }

  /// 総当たり戦の全試合が完了していれば、勝ち数最多者を優勝としてトーナ
  /// メントを完了にする。複数の試合がほぼ同時に完了しても、トランザクション
  /// 内で既にcompletedかどうかを確認するため二重確定は起きない。
  Future<void> _completeRoundRobinIfDone({required String tournamentId}) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);

    final matchesSnapshot = await tournamentRef.collection(matchesCollection).get();
    final matchRefs = matchesSnapshot.docs.map((doc) => doc.reference).toList();
    if (matchRefs.isEmpty) return;

    await _firestore.runTransaction<void>((transaction) async {
      final matches = <TournamentMatch>[];
      for (final ref in matchRefs) {
        matches.add(TournamentMatch.fromFirestore(await transaction.get(ref)));
      }

      if (matches.any((m) => !m.isCompleted)) {
        return; // まだ全節が終わっていない
      }

      final tournamentDoc = await transaction.get(tournamentRef);
      final tournament = Tournament.fromFirestore(tournamentDoc);
      if (tournament.status == 'completed') {
        return; // 既に別の呼び出しが確定済み
      }

      final championUid = _computeStandingsChampion(matches);
      transaction.update(tournamentRef, {
        'status': 'completed',
        'winnerId': championUid,
      });
      _logger.i('🏆 Round-robin tournament completed: $tournamentId winner=$championUid');
    });
  }

  /// 完了済み試合の勝敗から勝ち数最多の参加者を求める（同数はuid昇順）。
  String? _computeStandingsChampion(List<TournamentMatch> matches) {
    final wins = <String, int>{};
    final participants = <String>{};
    for (final m in matches) {
      if (m.player1Uid != null) participants.add(m.player1Uid!);
      if (m.player2Uid != null) participants.add(m.player2Uid!);
      if (m.winnerUid != null) {
        wins[m.winnerUid!] = (wins[m.winnerUid!] ?? 0) + 1;
      }
    }
    if (participants.isEmpty) return null;
    final sorted = participants.toList()
      ..sort((a, b) {
        final winsCompare = (wins[b] ?? 0).compareTo(wins[a] ?? 0);
        return winsCompare != 0 ? winsCompare : a.compareTo(b);
      });
    return sorted.first;
  }

  /// 総当たり戦の順位表。勝ち数の多い順（同数はuid昇順の簡易タイブレーク —
  /// 対戦成績・得失点差などの本格的なタイブレークは未実装、既知の制約）。
  Future<List<TournamentStandingEntry>> getStandings(String tournamentId) async {
    try {
      final matches = await getTournamentMatches(tournamentId: tournamentId);
      final wins = <String, int>{};
      final losses = <String, int>{};
      final names = <String, String>{};

      for (final m in matches) {
        if (m.player1Uid != null) names[m.player1Uid!] = m.player1DisplayName ?? 'Player';
        if (m.player2Uid != null) names[m.player2Uid!] = m.player2DisplayName ?? 'Player';
        if (!m.isCompleted || m.winnerUid == null) continue;
        wins[m.winnerUid!] = (wins[m.winnerUid!] ?? 0) + 1;
        final loserUid = m.player1Uid == m.winnerUid ? m.player2Uid : m.player1Uid;
        if (loserUid != null) losses[loserUid] = (losses[loserUid] ?? 0) + 1;
      }

      final entries = names.entries
          .map((e) => TournamentStandingEntry(
                uid: e.key,
                displayName: e.value,
                wins: wins[e.key] ?? 0,
                losses: losses[e.key] ?? 0,
              ))
          .toList()
        ..sort((a, b) {
          final winsCompare = b.wins.compareTo(a.wins);
          return winsCompare != 0 ? winsCompare : a.uid.compareTo(b.uid);
        });
      return entries;
    } catch (e) {
      _logger.e('Error computing standings: $e');
      rethrow;
    }
  }

  /// 指定ラウンドの全試合が完了していれば、勝者同士で次ラウンドを生成する。
  /// 勝者が1人だけならその人が優勝者としてトーナメントを完了させる。
  ///
  /// 同じラウンドの複数試合がほぼ同時に完了すると、それぞれの呼び出しが
  /// 「ラウンド完了」を独立に検知して次ラウンドを二重生成しうるため、
  /// Tournament.lastAdvancedRound をトランザクション内でチェック＆更新する
  /// ことで一度しか進行しないようにする。
  Future<void> _advanceRoundIfComplete({
    required String tournamentId,
    required int round,
  }) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);

    // コレクションクエリはトランザクション内で実行できないため、対象試合の
    // 参照だけ先に取得し、実際の内容はトランザクション内で読み直す。
    final roundMatchesSnapshot = await tournamentRef
        .collection(matchesCollection)
        .where('round', isEqualTo: round)
        .get();
    final matchRefs = roundMatchesSnapshot.docs.map((doc) => doc.reference).toList();
    if (matchRefs.isEmpty) return;

    await _firestore.runTransaction<void>((transaction) async {
      final roundMatches = <TournamentMatch>[];
      for (final ref in matchRefs) {
        final doc = await transaction.get(ref);
        roundMatches.add(TournamentMatch.fromFirestore(doc));
      }

      if (roundMatches.any((m) => !m.isCompleted)) {
        return; // まだ全試合が終わっていない
      }

      final tournamentDoc = await transaction.get(tournamentRef);
      final tournament = Tournament.fromFirestore(tournamentDoc);
      if (tournament.lastAdvancedRound >= round) {
        _logger.i('Round $round already advanced for $tournamentId, skipping');
        return; // 既に別の呼び出しがこのラウンドを処理済み
      }

      final winners = roundMatches.map((m) => m.winnerUid).whereType<String>().toList();

      if (winners.length <= 1) {
        final championUid = winners.isNotEmpty ? winners.first : null;
        transaction.update(tournamentRef, {
          'status': 'completed',
          'winnerId': championUid,
          'lastAdvancedRound': round,
        });
        _logger.i('🏆 Tournament completed: $tournamentId winner=$championUid');
        return;
      }

      final displayNames = <String, String>{
        for (final m in roundMatches) ...{
          if (m.player1Uid != null) m.player1Uid!: m.player1DisplayName ?? 'Player',
          if (m.player2Uid != null) m.player2Uid!: m.player2DisplayName ?? 'Player',
        },
      };

      _writeRound(
        transaction: transaction,
        tournamentRef: tournamentRef,
        round: round + 1,
        playerUids: winners,
        displayNames: displayNames,
      );
      transaction.update(tournamentRef, {'lastAdvancedRound': round});
      _logger.i('Advanced $tournamentId to round ${round + 1} with ${winners.length} players');
    });
  }

  /// _generateRoundのトランザクション版。単一のFirestoreトランザクション
  /// 内から呼び出し、次ラウンドの試合をアトミックに書き込む。
  void _writeRound({
    required Transaction transaction,
    required DocumentReference<Map<String, dynamic>> tournamentRef,
    required int round,
    required List<String> playerUids,
    required Map<String, String> displayNames,
  }) {
    final now = DateTime.now();
    for (var i = 0; i < playerUids.length; i += 2) {
      final player1Uid = playerUids[i];
      final hasOpponent = i + 1 < playerUids.length;
      final player2Uid = hasOpponent ? playerUids[i + 1] : null;

      final matchRef = tournamentRef.collection(matchesCollection).doc();
      final match = TournamentMatch(
        id: matchRef.id,
        tournamentId: tournamentRef.id,
        player1Uid: player1Uid,
        player1DisplayName: displayNames[player1Uid],
        player2Uid: player2Uid,
        player2DisplayName: player2Uid != null ? displayNames[player2Uid] : null,
        round: round,
        winnerUid: hasOpponent ? null : player1Uid,
        status: hasOpponent ? 'pending' : 'completed',
        scheduledAt: now,
        completedAt: hasOpponent ? null : now,
      );
      transaction.set(matchRef, match.toFirestore());
    }
  }

  /// 大会を中止する（主催者のみ）。開催予定/開催中のいずれからでも中止可能。
  /// 既に完了・中止済みの大会は対象外。
  Future<void> cancelTournament({
    required String tournamentId,
    required String uid,
  }) async {
    try {
      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final doc = await tournamentRef.get();
      if (!doc.exists) throw Exception('Tournament not found');

      final tournament = Tournament.fromFirestore(doc);
      if (tournament.createdBy != uid) {
        throw Exception('Only the organizer can cancel this tournament');
      }
      if (tournament.isCompleted || tournament.isCancelled) {
        throw Exception('Tournament is already ${tournament.status}');
      }

      await tournamentRef.update({'status': 'cancelled'});
      _logger.i('✅ Tournament cancelled by organizer: $tournamentId');
    } catch (e) {
      _logger.e('Error cancelling tournament: $e');
      rethrow;
    }
  }

  /// 大会を削除する（主催者のみ）。まだ誰も対局していない「開催予定」の
  /// 大会に限る（ブラケット/対戦カードが生成された後は履歴として残す）。
  /// 参加者の participants サブコレクションのドキュメントは、Firestoreの
  /// ルール上（各参加者自身のみが自分の参加ドキュメントを削除できる）
  /// 主催者側からは削除できないため、大会ドキュメントの削除後に孤立データ
  /// として残る（既知の制約。どの画面もparticipantsをcollectionGroupで
  /// 横断参照しないため、実害はない）。
  Future<void> deleteTournament({
    required String tournamentId,
    required String uid,
  }) async {
    try {
      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final doc = await tournamentRef.get();
      if (!doc.exists) return;

      final tournament = Tournament.fromFirestore(doc);
      if (tournament.createdBy != uid) {
        throw Exception('Only the organizer can delete this tournament');
      }
      if (!tournament.isUpcoming) {
        throw Exception('Only an upcoming tournament (before it starts) can be deleted');
      }

      await tournamentRef.delete();
      _logger.i('✅ Tournament deleted by organizer: $tournamentId');
    } catch (e) {
      _logger.e('Error deleting tournament: $e');
      rethrow;
    }
  }

  /// 大会情報を編集する（主催者のみ、募集中の「開催予定」の間だけ）。
  /// 形式（format）は編集不可 - 参加者がその形式を見て参加登録しているため、
  /// 途中で変えると既存参加者の期待と食い違う。渡された引数のみ更新する。
  Future<void> updateTournament({
    required String tournamentId,
    required String uid,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    int? boardSize,
  }) async {
    try {
      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final doc = await tournamentRef.get();
      if (!doc.exists) throw Exception('Tournament not found');

      final tournament = Tournament.fromFirestore(doc);
      if (tournament.createdBy != uid) {
        throw Exception('Only the organizer can edit this tournament');
      }
      if (!tournament.isUpcoming) {
        throw Exception('Only an upcoming tournament (before it starts) can be edited');
      }
      if (maxParticipants != null && maxParticipants < tournament.participantUids.length) {
        throw Exception('maxParticipants cannot be lower than the current participant count');
      }

      final updates = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (startDate != null) 'startDate': Timestamp.fromDate(startDate),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate),
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
        if (boardSize != null) 'boardSize': boardSize,
      };
      if (updates.isEmpty) return;

      await tournamentRef.update(updates);
      _logger.i('✅ Tournament updated by organizer: $tournamentId');
    } catch (e) {
      _logger.e('Error updating tournament: $e');
      rethrow;
    }
  }

  /// アクティブなトーナメント一覧
  Future<List<Tournament>> getActiveTournaments() async {
    try {
      _logger.i('Fetching active tournaments');

      final snapshot = await _firestore
          .collection(tournamentsCollection)
          .where('status', whereIn: ['active', 'upcoming'])
          .orderBy('startDate')
          .get();

      final tournaments = snapshot.docs
          .map((doc) => Tournament.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Active tournaments fetched: ${tournaments.length}');
      return tournaments;
    } catch (e) {
      _logger.e('Error fetching active tournaments: $e');
      rethrow;
    }
  }

  /// ユーザーが参加しているトーナメント
  Future<List<Tournament>> getUserTournaments(String uid) async {
    try {
      _logger.i('Fetching user tournaments: $uid');

      final snapshot = await _firestore
          .collection(tournamentsCollection)
          .where('participantUids', arrayContains: uid)
          .get();

      final tournaments = snapshot.docs
          .map((doc) => Tournament.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ User tournaments fetched: ${tournaments.length}');
      return tournaments;
    } catch (e) {
      _logger.e('Error fetching user tournaments: $e');
      rethrow;
    }
  }
}
