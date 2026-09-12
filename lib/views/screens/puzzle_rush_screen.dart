import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// PuzzleRushScreen - タイム制マラソン
///
/// Features:
/// - Timed puzzle solving marathon
/// - Difficulty levels (easy, normal, hard, expert)
/// - Real-time score calculation
/// - Combo tracking and multipliers
/// - Leaderboard rankings
/// - Accuracy metrics
/// - Statistics tracking
class PuzzleRushScreen extends ConsumerStatefulWidget {
  final String uid;
  final String difficulty;

  const PuzzleRushScreen({
    Key? key,
    required this.uid,
    this.difficulty = 'normal',
  }) : super(key: key);

  @override
  ConsumerState<PuzzleRushScreen> createState() => _PuzzleRushScreenState();
}

class _PuzzleRushScreenState extends ConsumerState<PuzzleRushScreen> {
  late int _timeRemainingSeconds;
  int _currentCombo = 0;

  @override
  void initState() {
    super.initState();
    _logger.i(
      'PuzzleRushScreen initialized - '
      'uid: ${widget.uid}, difficulty: ${widget.difficulty}',
    );
    _timeRemainingSeconds = 5 * 60; // 5 minutes
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _timeRemainingSeconds--;
        });
        if (_timeRemainingSeconds > 0) {
          _startTimer();
        } else {
          _logger.i('Puzzle Rush time expired');
          _handleSessionTimeout();
        }
      }
    });
  }

  void _handleSessionTimeout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('セッションが終了しました')),
    );
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    _logger.i('Building PuzzleRushScreen');

    final sessionAsync = ref.watch(
      startPuzzleRushProvider(
        (uid: widget.uid, difficulty: widget.difficulty),
      ),
    );

    final leaderboardAsync = ref.watch(
      puzzleRushLeaderboardProvider(widget.difficulty),
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Puzzle Rush'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: sessionAsync.when(
        data: (session) => _buildSession(context, ref, session, leaderboardAsync),
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildSession(
    BuildContext context,
    WidgetRef ref,
    PuzzleRushRecord session,
    AsyncValue<List<PuzzleRushLeaderboardEntry>> leaderboardAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Session info header
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '難易度',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          widget.difficulty.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '残り時間',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatTime(_timeRemainingSeconds),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: _timeRemainingSeconds < 30
                                ? Colors.red
                                : Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score and stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.amber.shade600, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'スコア',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${session.score}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.amber.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'コンボ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${session.maxCombo}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '解答数',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${session.solvedCount}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.green.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: session.solvedCount > 0
                        ? session.correctCount / session.solvedCount
                        : 0,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '正答率: ${session.solvedCount > 0 ? ((session.correctCount / session.solvedCount) * 100).toStringAsFixed(1) : '0.0'}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Puzzle list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '解答したパズル',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (session.puzzleIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'まだパズルを解答していません',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: session.puzzleIds.asMap().entries.map((e) {
                      final idx = e.key;
                      final puzzleId = e.value;
                      final isCorrect = idx < session.puzzleResults.length
                          ? session.puzzleResults[idx]
                          : false;
                      final solveTime = idx < session.solveTimes.length
                          ? session.solveTimes[idx]
                          : 0;

                      return Chip(
                        label: Text(
                          '${idx + 1}: ${solveTime}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Leaderboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'リーダーボード',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                leaderboardAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ランキングデータがありません',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.take(5).length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == 0
                                          ? Colors.amber.shade700
                                          : index == 1
                                              ? Colors.grey.shade600
                                              : Colors.orange.shade700,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.uid.substring(0, 8),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        '正答率: ${entry.accuracy}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${entry.score}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  color: Colors.amber.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) {
                    _logger.e('Error loading leaderboard: $error');
                    return Text(
                      'リーダーボード読み込みエラー',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // End session button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleEndSession(context, ref, session),
                icon: const Icon(Icons.stop_circle),
                label: const Text('セッションを終了'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleEndSession(
    BuildContext context,
    WidgetRef ref,
    PuzzleRushRecord session,
  ) async {
    _logger.i('Ending Puzzle Rush session: ${session.id}');

    try {
      await ref.read(
        endPuzzleRushProvider(session.id).future,
      );

      _logger.i('Session ended successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('セッションを終了しました')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _logger.e('Error ending session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'セッションを準備中...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logger.i('PuzzleRushScreen disposed');
    super.dispose();
  }
}
