import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';
import 'package:goen/viewmodels/index.dart';
import 'tournament_bracket_screen.dart';

final _logger = Logger();

/// トーナメント画面 - 開催中/参加中のトーナメント一覧と参加
class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('トーナメント'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber[600],
          labelColor: Colors.amber[600],
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(text: '開催中'),
            Tab(text: '参加中'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTournaments(uid),
          uid == null
              ? const Center(
                  child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
                )
              : _buildUserTournaments(uid),
        ],
      ),
    );
  }

  Widget _buildActiveTournaments(String? uid) {
    final tournamentsAsync = ref.watch(activeTournamentsProvider);
    return tournamentsAsync.when(
      data: (tournaments) {
        if (tournaments.isEmpty) {
          return Center(
            child: Text('開催中のトーナメントはありません', style: TextStyle(color: Colors.grey[500])),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tournaments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildTournamentCard(tournaments[index], uid),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Active tournaments error: $err');
        return Center(child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)));
      },
    );
  }

  Widget _buildUserTournaments(String uid) {
    final tournamentsAsync = ref.watch(userTournamentsProvider(uid));
    return tournamentsAsync.when(
      data: (tournaments) {
        if (tournaments.isEmpty) {
          return Center(
            child: Text('参加中のトーナメントはありません', style: TextStyle(color: Colors.grey[500])),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tournaments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildTournamentCard(tournaments[index], uid),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('User tournaments error: $err');
        return Center(child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)));
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament, String? uid) {
    final alreadyJoined = uid != null && tournament.participantUids.contains(uid);

    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TournamentBracketScreen(tournament: tournament)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(tournament),
                ],
              ),
              const SizedBox(height: 6),
              Text(tournament.description, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.group, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.participantUids.length}/${tournament.maxParticipants}人',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.format_list_bulleted, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(_formatFormat(tournament.format), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(tournament.startDate)} 〜 ${_formatDate(tournament.endDate)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (tournament.isUpcoming && uid != null && !alreadyJoined && !tournament.isFull) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600]),
                    onPressed: () => _joinTournament(context, tournament),
                    child: const Text('参加する', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (alreadyJoined)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 6),
                      Text('参加済み', style: TextStyle(color: Colors.greenAccent[100])),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Tournament tournament) {
    final Color color;
    final String label;
    if (tournament.isActive) {
      color = Colors.green;
      label = '開催中';
    } else if (tournament.isCompleted) {
      color = Colors.grey;
      label = '終了';
    } else {
      color = Colors.amber;
      label = '開催予定';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _formatFormat(String format) {
    switch (format) {
      case 'single_elimination':
        return 'トーナメント形式';
      case 'round_robin':
        return '総当たり戦';
      case 'swiss':
        return 'スイス式';
      default:
        return format;
    }
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}';

  Future<void> _joinTournament(BuildContext context, Tournament tournament) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final success = await ref.read(joinTournamentProvider)(
        tournamentId: tournament.id,
        uid: currentUser.uid,
        displayName: currentUser.displayName ?? 'Player',
      );
      if (!context.mounted) return;
      if (success) {
        ref.invalidate(activeTournamentsProvider);
        ref.invalidate(userTournamentsProvider(currentUser.uid));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('トーナメントに参加しました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('参加できませんでした（満員の可能性があります）')),
        );
      }
    } catch (e) {
      _logger.e('Error joining tournament: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }
}
