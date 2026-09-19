import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'pvp_game_screen.dart';

final _logger = Logger();

/// 実力マッチングEngine画面 - レートの近い相手との「運命の対戦」
class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  int _boardSize = 19;
  bool _isSearching = false;
  bool _isStartingGame = false;
  MatchResult? _foundMatch;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('実力マッチング'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'レートが近い相手を探して、運命の対戦を始めましょう',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),
                  _buildBoardSizeSelector(),
                  const SizedBox(height: 20),
                  if (_foundMatch != null) _buildMatchFoundCard(_foundMatch!, uid, currentUser!),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : () => _findMatch(uid, currentUser!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              '対戦相手を探す',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'これまでの対戦',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildMatchHistory(uid),
                ],
              ),
            ),
    );
  }

  Widget _buildBoardSizeSelector() {
    return Row(
      children: [9, 13, 19].map((size) {
        final selected = _boardSize == size;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('$size路盤'),
            selected: selected,
            onSelected: (_) => setState(() => _boardSize = size),
            selectedColor: Colors.amber[600],
            backgroundColor: Colors.grey[800],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchFoundCard(MatchResult match, String uid, User currentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber[600]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.amber[600]?.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, color: Colors.amber[600]),
              const SizedBox(width: 8),
              const Text(
                '運命の対戦が見つかりました！',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${match.player1DisplayName} (${match.player1Rating}) vs '
            '${match.player2DisplayName} (${match.player2Rating})',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'レート差: ${match.ratingDiff} / ${match.boardSize}路盤',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          if (match.gameId == null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isStartingGame ? null : () => _startGame(match, uid, currentUser),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                child: _isStartingGame
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('対局を開始する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchHistory(String uid) {
    final historyAsync = ref.watch(matchHistoryProvider(uid));
    return historyAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Text('まだ対戦履歴がありません', style: TextStyle(color: Colors.grey[500]));
        }
        return Column(
          children: matches.map((match) {
            final isPlayer1 = match.player1Uid == uid;
            final opponentName = isPlayer1 ? match.player2DisplayName : match.player1DisplayName;
            final opponentRating = isPlayer1 ? match.player2Rating : match.player1Rating;
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.white70),
                title: Text(opponentName, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'レート $opponentRating / ${match.boardSize}路盤',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: match.gameId != null
                    ? const Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16)
                    : null,
                onTap: match.gameId == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PvpGameScreen(gameId: match.gameId!, uid: uid),
                          ),
                        ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Match history error: $err');
        return Text('エラー: $err', style: const TextStyle(color: Colors.redAccent));
      },
    );
  }

  Future<void> _findMatch(String uid, User currentUser) async {
    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final rankEntry = await ref.read(userLeaderboardRankProvider(
        (uid: uid, period: LeaderboardPeriod.allTime, type: LeaderboardType.rating),
      ).future);
      final rating = rankEntry?.rating ?? 1200;
      final displayName = currentUser.displayName ?? 'Player';

      await ref.read(joinMatchmakingQueueProvider)(uid, displayName, rating, _boardSize);
      final match = await ref.read(findMatchProvider)(uid, displayName, rating, _boardSize);

      if (!mounted) return;
      setState(() {
        _foundMatch = match;
        _error = match == null ? '今は条件に合う相手が見つかりませんでした。また試してください' : null;
      });

      if (match != null) {
        ref.invalidate(matchHistoryProvider(uid));
      }
    } catch (e) {
      _logger.e('Error finding match: $e');
      if (mounted) {
        setState(() => _error = 'エラーが発生しました: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _startGame(MatchResult match, String uid, User currentUser) async {
    setState(() => _isStartingGame = true);
    try {
      final isPlayer1 = match.player1Uid == uid;
      final opponentUid = isPlayer1 ? match.player2Uid : match.player1Uid;
      final opponentName = isPlayer1 ? match.player2DisplayName : match.player1DisplayName;
      final myName = currentUser.displayName ?? 'Player';

      // マッチを見つけた側が黒番（先手）を持つ。
      final game = await ref.read(createPvpGameProvider)(
        match.boardSize,
        uid,
        myName,
        opponentUid,
        opponentName,
        matchId: match.id,
      );

      await ref.read(attachGameToMatchProvider)(match.id, game.id);

      try {
        await ref.read(sendNotificationProvider)(
          uid: opponentUid,
          title: '$myName さんとの対局が始まりました',
          body: 'マッチングで見つかった相手との対局です。今すぐ打ちましょう！',
          type: 'pvp_challenge',
          data: {'gameId': game.id},
        );
      } catch (e) {
        _logger.w('Failed to notify opponent of new PvP game (non-fatal): $e');
      }

      if (!mounted) return;
      ref.invalidate(matchHistoryProvider(uid));
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PvpGameScreen(gameId: game.id, uid: uid)),
      );
    } catch (e) {
      _logger.e('Error starting PvP game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('対局を開始できませんでした: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingGame = false);
      }
    }
  }
}
