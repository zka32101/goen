import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';
import 'package:goen/viewmodels/index.dart';
import 'pvp_game_screen.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// トーナメントのブラケット画面 - ラウンドごとの対戦組み合わせと結果
class TournamentBracketScreen extends ConsumerStatefulWidget {
  final Tournament tournament;

  const TournamentBracketScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  ConsumerState<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends ConsumerState<TournamentBracketScreen> {
  bool _isStarting = false;
  bool _isCreatingGame = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;
    final matchesAsync = ref.watch(
      tournamentMatchesProvider((tournamentId: widget.tournament.id, round: null)),
    );

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: Text(widget.tournament.name),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
      ),
      body: matchesAsync.when(
        data: (matches) => _buildContent(context, matches, uid, currentUser?.displayName),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          _logger.e('Tournament matches error: $err');
          return Center(child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)));
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<TournamentMatch> matches,
    String? uid,
    String? myDisplayName,
  ) {
    if (widget.tournament.isUpcoming) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'まだブラケットは作成されていません',
                style: TextStyle(color: AppColors.washiDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.tournament.participantUids.length >= 2)
                ElevatedButton(
                  onPressed: _isStarting ? null : () => _startTournament(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
                  child: _isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('トーナメントを開始する', style: TextStyle(color: AppColors.sumi)),
                )
              else
                Text(
                  '開始には最低2人の参加者が必要です',
                  style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                ),
            ],
          ),
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Text('試合データがありません', style: TextStyle(color: AppColors.washiDim)),
      );
    }

    final byRound = <int, List<TournamentMatch>>{};
    for (final match in matches) {
      byRound.putIfAbsent(match.round, () => []).add(match);
    }
    final rounds = byRound.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.tournament.isCompleted) _buildChampionBanner(matches),
        for (final round in rounds) ...[
          Text(
            round == rounds.last && widget.tournament.isCompleted ? '決勝' : '第$round回戦',
            style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...byRound[round]!.map((match) => _buildMatchCard(context, match, uid, myDisplayName)),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildChampionBanner(List<TournamentMatch> matches) {
    final winnerId = widget.tournament.winnerId;
    final championName = winnerId == null ? null : _resolveDisplayName(matches, winnerId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kin, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.kin.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: AppColors.kin, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              championName != null ? '優勝: $championName' : 'トーナメント終了',
              style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 試合一覧のplayer1/player2表示名から、指定uidの表示名を探す。
  String? _resolveDisplayName(List<TournamentMatch> matches, String uid) {
    for (final match in matches) {
      if (match.player1Uid == uid && match.player1DisplayName != null) {
        return match.player1DisplayName;
      }
      if (match.player2Uid == uid && match.player2DisplayName != null) {
        return match.player2DisplayName;
      }
    }
    return null;
  }

  Widget _buildMatchCard(
    BuildContext context,
    TournamentMatch match,
    String? uid,
    String? myDisplayName,
  ) {
    final isMyMatch = uid != null && (match.player1Uid == uid || match.player2Uid == uid);
    final canStart = isMyMatch &&
        match.isPending &&
        !match.isBye &&
        match.gameId == null &&
        myDisplayName != null;

    return Card(
      color: isMyMatch ? AppColors.kin.withOpacity(0.08) : AppColors.sumiSurface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildPlayerLabel(match.player1Uid, match.player1DisplayName, match.winnerUid)),
                Text(match.isBye ? 'BYE' : 'vs', style: TextStyle(color: AppColors.washiDim)),
                Expanded(
                  child: _buildPlayerLabel(
                    match.player2Uid,
                    match.player2DisplayName,
                    match.winnerUid,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            if (canStart || match.gameId != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: match.gameId != null
                      ? () => _openGame(context, match.gameId!, uid!)
                      : (_isCreatingGame ? null : () => _startMatch(context, match, uid!, myDisplayName!)),
                  child: Text(match.gameId != null ? '対局を見る' : '対局を開始する'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerLabel(
    String? uid,
    String? displayName,
    String? winnerUid, {
    bool alignEnd = false,
  }) {
    if (uid == null) {
      return Text(
        '(不戦勝待ち)',
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: TextStyle(color: AppColors.washiDim, fontStyle: FontStyle.italic),
      );
    }
    final isWinner = winnerUid == uid;
    return Text(
      displayName ?? 'Player',
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: TextStyle(
        color: isWinner ? AppColors.kin : AppColors.washi,
        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Future<void> _startTournament(BuildContext context) async {
    setState(() => _isStarting = true);
    try {
      await ref.read(startTournamentProvider)(widget.tournament.id);
      ref.invalidate(tournamentMatchesProvider((tournamentId: widget.tournament.id, round: null)));
      ref.invalidate(activeTournamentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('トーナメントを開始しました')),
        );
      }
    } catch (e) {
      _logger.e('Error starting tournament: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('開始できませんでした: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _startMatch(
    BuildContext context,
    TournamentMatch match,
    String uid,
    String myDisplayName,
  ) async {
    setState(() => _isCreatingGame = true);
    try {
      final opponentUid = match.player1Uid == uid ? match.player2Uid! : match.player1Uid!;
      final opponentName =
          (match.player1Uid == uid ? match.player2DisplayName : match.player1DisplayName) ?? 'Player';

      // 対戦カード内でUIDの小さい方を黒番にする（両対局者が同じ結果になるようにするため）。
      final amIBlack = uid.compareTo(opponentUid) < 0;
      // トランザクションで排他制御されるため、両対局者がほぼ同時にタップしても
      // 対局は1つしか作られず、後から来た方は同じgameIdを受け取る。
      final gameId = await ref.read(createTournamentGameProvider)(
        widget.tournament.id,
        match.id,
        widget.tournament.boardSize,
        amIBlack ? uid : opponentUid,
        amIBlack ? myDisplayName : opponentName,
        amIBlack ? opponentUid : uid,
        amIBlack ? opponentName : myDisplayName,
      );

      ref.invalidate(tournamentMatchesProvider((tournamentId: widget.tournament.id, round: null)));

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PvpGameScreen(gameId: gameId, uid: uid)),
      );
    } catch (e) {
      _logger.e('Error starting tournament match: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('対局を開始できませんでした: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingGame = false);
    }
  }

  void _openGame(BuildContext context, String gameId, String uid) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PvpGameScreen(gameId: gameId, uid: uid)),
    );
  }
}
