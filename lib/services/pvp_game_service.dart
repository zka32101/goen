import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/pvp_game.dart';
import 'go_rules.dart';

final _logger = Logger();

/// PvP対局サービス - マッチング成立後の2人プレイヤー間リアルタイム対局
class PvpGameService {
  final FirebaseFirestore _firestore;

  PvpGameService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection('pvp_games');

  /// マッチングエンジン経由の対局を作成する。トーナメント試合の対局は
  /// 排他制御が必要なため createGameForTournamentMatch を使うこと。
  Future<PvpGame> createGame({
    required int boardSize,
    required String blackUid,
    required String blackDisplayName,
    required String whiteUid,
    required String whiteDisplayName,
    String? matchId,
  }) async {
    try {
      final docRef = _games.doc();
      final game = PvpGame(
        id: docRef.id,
        boardSize: boardSize,
        blackUid: blackUid,
        blackDisplayName: blackDisplayName,
        whiteUid: whiteUid,
        whiteDisplayName: whiteDisplayName,
        stones: List.generate(boardSize, (_) => List.filled(boardSize, 0)),
        isBlackTurn: true,
        capturedBlack: 0,
        capturedWhite: 0,
        movesCount: 0,
        consecutivePasses: 0,
        status: 'active',
        matchId: matchId,
        createdAt: DateTime.now(),
      );
      await docRef.set(game.toFirestore());
      _logger.i('Created PvP game: ${docRef.id}');
      return game;
    } catch (e) {
      _logger.e('Error creating PvP game: $e');
      rethrow;
    }
  }

  /// トーナメント試合に対する対局を作成する。両対局者がほぼ同時に
  /// 「対局を開始する」を押しても対局が2つ作られないよう、
  /// 「試合にまだgameIdが無ければ作成する」をFirestoreトランザクションで
  /// アトミックに行う。既に対局が存在すれば新規作成せずそのgameIdを返す。
  Future<String> createGameForTournamentMatch({
    required String tournamentId,
    required String matchId,
    required int boardSize,
    required String blackUid,
    required String blackDisplayName,
    required String whiteUid,
    required String whiteDisplayName,
  }) async {
    try {
      return await _firestore.runTransaction<String>((transaction) async {
        final matchRef = _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('matches')
            .doc(matchId);
        final matchDoc = await transaction.get(matchRef);
        final existingGameId = matchDoc.data()?['gameId'] as String?;
        if (existingGameId != null) {
          _logger.i('Tournament match $matchId already has a game: $existingGameId');
          return existingGameId;
        }

        final gameRef = _games.doc();
        final game = PvpGame(
          id: gameRef.id,
          boardSize: boardSize,
          blackUid: blackUid,
          blackDisplayName: blackDisplayName,
          whiteUid: whiteUid,
          whiteDisplayName: whiteDisplayName,
          stones: List.generate(boardSize, (_) => List.filled(boardSize, 0)),
          isBlackTurn: true,
          capturedBlack: 0,
          capturedWhite: 0,
          movesCount: 0,
          consecutivePasses: 0,
          status: 'active',
          tournamentId: tournamentId,
          tournamentMatchId: matchId,
          createdAt: DateTime.now(),
        );
        transaction.set(gameRef, game.toFirestore());
        transaction.update(matchRef, {'gameId': gameRef.id, 'status': 'in_progress'});

        _logger.i('Created PvP game ${gameRef.id} for tournament match $matchId');
        return gameRef.id;
      });
    } catch (e) {
      _logger.e('Error creating game for tournament match: $e');
      rethrow;
    }
  }

  Future<PvpGame?> getGame(String gameId) async {
    try {
      final doc = await _games.doc(gameId).get();
      if (!doc.exists) return null;
      return PvpGame.fromFirestore(doc);
    } catch (e) {
      _logger.e('Error getting PvP game: $e');
      rethrow;
    }
  }

  Stream<PvpGame?> streamGame(String gameId) {
    return _games.doc(gameId).snapshots().map(
          (doc) => doc.exists ? PvpGame.fromFirestore(doc) : null,
        );
  }

  Future<List<PvpGame>> getUserActiveGames(String uid) async {
    try {
      final asBlack = await _games
          .where('blackUid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();
      final asWhite = await _games
          .where('whiteUid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();
      return [
        ...asBlack.docs.map(PvpGame.fromFirestore),
        ...asWhite.docs.map(PvpGame.fromFirestore),
      ];
    } catch (e) {
      _logger.e('Error getting user active PvP games: $e');
      rethrow;
    }
  }

  /// 手を打つ。トランザクションで読み取り・検証・書き込みを行い、
  /// 2人が同時に操作しても不整合が起きないようにする。
  /// 戻り値: 成功時true、非合法手やターン違反ならfalse。
  Future<bool> applyMove({
    required String gameId,
    required String uid,
    required int row,
    required int col,
  }) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final docRef = _games.doc(gameId);
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          _logger.w('PvP game not found: $gameId');
          return false;
        }

        final game = PvpGame.fromFirestore(snapshot);
        if (!game.isActive) {
          _logger.w('PvP game already finished: $gameId');
          return false;
        }
        if (!game.isTurnOf(uid)) {
          _logger.w('Not $uid\'s turn in game $gameId');
          return false;
        }

        final player = game.isBlackTurn ? 1 : 2;
        final result = GoRules.applyMove(
          stones: game.stones,
          boardSize: game.boardSize,
          row: row,
          col: col,
          player: player,
          koRow: game.koRow,
          koCol: game.koCol,
        );

        if (result == null) {
          _logger.w('Illegal PvP move rejected: game=$gameId [$row,$col]');
          return false;
        }

        transaction.update(docRef, {
          'stones': result.stones.map((r) => r.join()).toList(),
          'capturedBlack': player == 2 ? game.capturedBlack + result.capturedCount : game.capturedBlack,
          'capturedWhite': player == 1 ? game.capturedWhite + result.capturedCount : game.capturedWhite,
          'isBlackTurn': !game.isBlackTurn,
          'koRow': result.koRow,
          'koCol': result.koCol,
          'lastMoveRow': row,
          'lastMoveCol': col,
          'movesCount': game.movesCount + 1,
          'consecutivePasses': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _logger.i('PvP move applied: game=$gameId player=$player [$row,$col]');
        return true;
      });
    } catch (e) {
      _logger.e('Error applying PvP move: $e');
      rethrow;
    }
  }

  /// パスする。2連続パスで終局とし、暫定的に地合いの多い側を勝者にする
  /// （簡易スコアリング：正式な地合い計算はFuegoエンジンに委ねていないため、
  /// 石数差での概算。既存のGoEngineによる正式な判定はAI対局専用のため）。
  Future<bool> pass({required String gameId, required String uid}) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final docRef = _games.doc(gameId);
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        final game = PvpGame.fromFirestore(snapshot);
        if (!game.isActive || !game.isTurnOf(uid)) return false;

        final consecutivePasses = game.consecutivePasses + 1;
        final gameEnded = consecutivePasses >= 2;

        final update = <String, dynamic>{
          'isBlackTurn': !game.isBlackTurn,
          'koRow': null,
          'koCol': null,
          'consecutivePasses': consecutivePasses,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (gameEnded) {
          final winnerUid = _estimateWinner(game);
          update['status'] = 'finished';
          update['winnerUid'] = winnerUid;
          update['result'] = 'score';
        }

        transaction.update(docRef, update);
        _logger.i('PvP pass: game=$gameId uid=$uid ended=$gameEnded');
        return true;
      });
    } catch (e) {
      _logger.e('Error passing PvP game: $e');
      rethrow;
    }
  }

  String? _estimateWinner(PvpGame game) {
    var blackStones = 0;
    var whiteStones = 0;
    for (final row in game.stones) {
      for (final cell in row) {
        if (cell == 1) blackStones++;
        if (cell == 2) whiteStones++;
      }
    }
    final blackScore = blackStones + game.capturedWhite;
    final whiteScore = whiteStones + game.capturedBlack;
    if (blackScore == whiteScore) return null;
    return blackScore > whiteScore ? game.blackUid : game.whiteUid;
  }

  Future<void> resign({required String gameId, required String uid}) async {
    try {
      final game = await getGame(gameId);
      if (game == null || !game.isActive) return;

      final winnerUid = game.playerColorOf(uid) == 1 ? game.whiteUid : game.blackUid;
      await _games.doc(gameId).update({
        'status': 'finished',
        'winnerUid': winnerUid,
        'result': 'resignation',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('PvP game resigned: game=$gameId by=$uid');
    } catch (e) {
      _logger.e('Error resigning PvP game: $e');
      rethrow;
    }
  }
}
