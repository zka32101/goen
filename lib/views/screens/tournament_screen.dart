import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';
import 'package:goen/viewmodels/index.dart';
import 'tournament_bracket_screen.dart';
import 'tournament_create_screen.dart';
import 'package:goen/config/theme.dart';

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
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('トーナメント'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kin,
          labelColor: AppColors.kin,
          unselectedLabelColor: AppColors.washiDim,
          tabs: const [
            Tab(text: '開催中'),
            Tab(text: '参加中'),
          ],
        ),
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.kin,
              icon: const Icon(Icons.add, color: AppColors.sumi),
              label: const Text('大会を作成', style: TextStyle(color: AppColors.sumi)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TournamentCreateScreen()),
              ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTournaments(uid),
          uid == null
              ? const Center(
                  child: Text('ログインが必要です', style: TextStyle(color: AppColors.washiDim)),
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
            child: Text('開催中のトーナメントはありません', style: TextStyle(color: AppColors.washiDim)),
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
            child: Text('参加中のトーナメントはありません', style: TextStyle(color: AppColors.washiDim)),
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
      color: AppColors.sumiSurface,
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
                      style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(tournament),
                ],
              ),
              const SizedBox(height: 6),
              Text(tournament.description, style: TextStyle(color: AppColors.washiDim, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.group, size: 16, color: AppColors.washiDim),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.participantUids.length}/${tournament.maxParticipants}人',
                    style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.format_list_bulleted, size: 16, color: AppColors.washiDim),
                  const SizedBox(width: 4),
                  Text(_formatFormat(tournament.format), style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
                  const SizedBox(width: 16),
                  Icon(Icons.grid_on, size: 16, color: AppColors.washiDim),
                  const SizedBox(width: 4),
                  Text('${tournament.boardSize}路盤', style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(tournament.startDate)} 〜 ${_formatDate(tournament.endDate)}',
                style: TextStyle(color: AppColors.washiDim, fontSize: 12),
              ),
              if (tournament.isUpcoming && uid != null && !alreadyJoined && !tournament.isFull) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
                    onPressed: () => _joinTournament(context, tournament),
                    child: const Text('参加する', style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.bold)),
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
      color = AppColors.kin;
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
