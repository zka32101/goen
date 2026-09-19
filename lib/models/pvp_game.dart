import 'package:cloud_firestore/cloud_firestore.dart';

/// 2人のプレイヤー間のリアルタイム対局（マッチング成立後の実対局）
class PvpGame {
  final String id;
  final int boardSize;
  final String blackUid;
  final String blackDisplayName;
  final String whiteUid;
  final String whiteDisplayName;
  final List<List<int>> stones; // 0=空, 1=黒, 2=白
  final bool isBlackTurn;
  final int capturedBlack;
  final int capturedWhite;
  final int? koRow;
  final int? koCol;
  final int? lastMoveRow;
  final int? lastMoveCol;
  final int movesCount;
  final int consecutivePasses;
  final String status; // 'active', 'finished'
  final String? winnerUid;
  final String? result; // 'resignation', 'score', null(進行中)
  final String? matchId; // matching engineのMatchResult.idとの紐付け（あれば）
  final String? tournamentId; // トーナメント試合の場合の大会ID
  final String? tournamentMatchId; // トーナメント試合の場合のTournamentMatch ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  PvpGame({
    required this.id,
    required this.boardSize,
    required this.blackUid,
    required this.blackDisplayName,
    required this.whiteUid,
    required this.whiteDisplayName,
    required this.stones,
    required this.isBlackTurn,
    required this.capturedBlack,
    required this.capturedWhite,
    this.koRow,
    this.koCol,
    this.lastMoveRow,
    this.lastMoveCol,
    required this.movesCount,
    required this.consecutivePasses,
    required this.status,
    this.winnerUid,
    this.result,
    this.matchId,
    this.tournamentId,
    this.tournamentMatchId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isFinished => status == 'finished';

  /// uidが黒番なら1、白番なら2、対局者でなければ0
  int playerColorOf(String uid) {
    if (uid == blackUid) return 1;
    if (uid == whiteUid) return 2;
    return 0;
  }

  bool isTurnOf(String uid) {
    final color = playerColorOf(uid);
    if (color == 0) return false;
    return (color == 1) == isBlackTurn;
  }

  factory PvpGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    // Firestoreは配列のネストを禁止しているため、各行を数字文字列
    // ("0120...")としてエンコードして保存している（SpectatorSessionと同様）。
    final boardSize = data['boardSize'] as int? ?? 19;
    final rawRows = data['stones'] as List<dynamic>?;
    final stones = rawRows != null
        ? rawRows.map((row) => (row as String).split('').map(int.parse).toList()).toList()
        : List.generate(boardSize, (_) => List.filled(boardSize, 0));

    return PvpGame(
      id: doc.id,
      boardSize: boardSize,
      blackUid: data['blackUid'] as String? ?? '',
      blackDisplayName: data['blackDisplayName'] as String? ?? 'Black',
      whiteUid: data['whiteUid'] as String? ?? '',
      whiteDisplayName: data['whiteDisplayName'] as String? ?? 'White',
      stones: stones,
      isBlackTurn: data['isBlackTurn'] as bool? ?? true,
      capturedBlack: data['capturedBlack'] as int? ?? 0,
      capturedWhite: data['capturedWhite'] as int? ?? 0,
      koRow: data['koRow'] as int?,
      koCol: data['koCol'] as int?,
      lastMoveRow: data['lastMoveRow'] as int?,
      lastMoveCol: data['lastMoveCol'] as int?,
      movesCount: data['movesCount'] as int? ?? 0,
      consecutivePasses: data['consecutivePasses'] as int? ?? 0,
      status: data['status'] as String? ?? 'active',
      winnerUid: data['winnerUid'] as String?,
      result: data['result'] as String?,
      matchId: data['matchId'] as String?,
      tournamentId: data['tournamentId'] as String?,
      tournamentMatchId: data['tournamentMatchId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'boardSize': boardSize,
      'blackUid': blackUid,
      'blackDisplayName': blackDisplayName,
      'whiteUid': whiteUid,
      'whiteDisplayName': whiteDisplayName,
      'stones': stones.map((row) => row.join()).toList(),
      'isBlackTurn': isBlackTurn,
      'capturedBlack': capturedBlack,
      'capturedWhite': capturedWhite,
      'koRow': koRow,
      'koCol': koCol,
      'lastMoveRow': lastMoveRow,
      'lastMoveCol': lastMoveCol,
      'movesCount': movesCount,
      'consecutivePasses': consecutivePasses,
      'status': status,
      'winnerUid': winnerUid,
      'result': result,
      'matchId': matchId,
      'tournamentId': tournamentId,
      'tournamentMatchId': tournamentMatchId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }
}
