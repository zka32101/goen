import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../widgets/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// Friends management screen
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // currentUserProvider is a plain Provider<User?> (not an AsyncValue).
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('フレンド'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'フレンド'),
            Tab(text: '招待待ち'),
            Tab(text: 'ブロック中'),
          ],
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('ログインしてください'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(currentUser.uid),
                _buildPendingRequests(currentUser.uid),
                _buildBlockedUsers(currentUser.uid),
              ],
            ),
      floatingActionButton: currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showSearchDialog(context),
              backgroundColor: AppColors.kin,
              child: const Icon(Icons.person_add),
            ),
    );
  }

  Widget _buildFriendsList(String uid) {
    final friendsAsync = ref.watch(friendsStreamProvider(uid));

    return friendsAsync.when(
      data: (friends) {
        return FriendListWidget(
          friends: friends,
          isLoading: false,
          onRefresh: () async {
            // Trigger refresh via Riverpod
            ref.refresh(friendsStreamProvider(uid));
          },
          onTap: (friend) {
            _showMessage(context, 'プロフィール表示は準備中です');
          },
          onMessage: (friend) {
            _showMessage(context, 'メッセージ機能は準備中です');
          },
          onInvite: (friend) {
            _showGameInviteDialog(context, uid, friend.uid, friend.displayName);
          },
          onBlock: (friend) {
            _blockFriend(context, uid, friend.uid);
          },
        );
      },
      loading: () => const FriendListWidget(
        friends: [],
        isLoading: true,
      ),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  Widget _buildPendingRequests(String uid) {
    final pendingAsync = ref.watch(pendingFriendRequestsProvider(uid));

    return pendingAsync.when(
      data: (pending) {
        if (pending.isEmpty) {
          return Center(
            child: Text('待機中のリクエストはありません',
                style: TextStyle(color: AppColors.washiDim)),
          );
        }

        return ListView.builder(
          itemCount: pending.length,
          itemBuilder: (context, index) {
            final request = pending[index];
            return _buildPendingRequestTile(context, uid, request);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  Widget _buildPendingRequestTile(
    BuildContext context,
    String uid,
    Friend request,
  ) {
    return Card(
      color: AppColors.kin.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.kin,
              radius: 24,
              child: const Icon(Icons.person, color: AppColors.washi),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.displayName,
                    style: const TextStyle(
                      color: AppColors.washi,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'リクエスト待機中',
                    style: TextStyle(color: AppColors.kin, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  _acceptFriendRequest(context, uid, request.uid),
              icon: const Icon(Icons.check),
              label: const Text('承認'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wakatake,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _blockFriend(context, uid, request.uid),
              icon: const Icon(Icons.close),
              label: const Text('拒否'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.shuLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedUsers(String uid) {
    final blockedFuture = ref.watch(
      FutureProvider((ref) async {
        final service = ref.watch(friendServiceProvider);
        return service.getBlockedUsers(uid: uid);
      }),
    );

    return blockedFuture.when(
      data: (blocked) {
        if (blocked.isEmpty) {
          return Center(
            child: Text('ブロック中のユーザーはいません',
                style: TextStyle(color: AppColors.washiDim)),
          );
        }

        return ListView.builder(
          itemCount: blocked.length,
          itemBuilder: (context, index) {
            final user = blocked[index];
            return Card(
              color: AppColors.sumiSurface,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.shuLight,
                      radius: 24,
                      child: const Icon(Icons.person, color: AppColors.washi),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: const TextStyle(
                          color: AppColors.washi,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          _unblockUser(context, uid, user.uid),
                      child: const Text('ブロック解除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.washiDim,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FriendSearchDialog(
        onSearch: (query) {
          Navigator.pop(context);
          _searchFriends(context, query);
        },
      ),
    );
  }

  void _searchFriends(BuildContext context, String query) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sumiSurface,
      builder: (context) {
        final resultsAsync = ref.watch(searchUsersProvider(query));

        return resultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return Center(
                child: Text('ユーザーが見つかりません',
                    style: TextStyle(color: AppColors.washiDim)),
              );
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final user = results[index];
                return ListTile(
                  title: Text(user.displayName,
                      style: const TextStyle(color: AppColors.washi)),
                  subtitle: Text('${user.totalGamesPlayed} games',
                      style: TextStyle(color: AppColors.washiDim)),
                  trailing: ElevatedButton(
                    onPressed: () => _addFriend(context, user.uid),
                    child: const Text('追加'),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('エラー: $err')),
        );
      },
    );
  }

  void _handleFriendAction(
    BuildContext context,
    String uid,
    Friend friend,
    String action,
  ) {
    switch (action) {
      case 'message':
        _showMessage(context, 'メッセージ機能は準備中です');
        break;
      case 'invite':
        _showGameInviteDialog(context, uid, friend.uid, friend.displayName);
        break;
      case 'profile':
        _showMessage(context, 'プロフィール表示は準備中です');
        break;
      case 'block':
        _blockFriend(context, uid, friend.uid);
        break;
    }
  }

  void _addFriend(BuildContext context, String friendUid) async {
    // currentUserProvider is a plain Provider<User?> (not an AsyncValue).
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final success = await ref.read(
      addFriendProvider((currentUser.uid, friendUid, null)).future,
    );

    if (!mounted) return;
    _showMessage(context, success ? 'リクエストを送信しました' : 'エラーが発生しました');
    if (success) Navigator.pop(context);
  }

  void _acceptFriendRequest(
    BuildContext context,
    String uid,
    String friendUid,
  ) async {
    final success = await ref.read(
      acceptFriendRequestProvider((uid, friendUid)).future,
    );

    if (!mounted) return;
    _showMessage(context, success ? 'フレンドになりました' : 'エラーが発生しました');
  }

  void _blockFriend(BuildContext context, String uid, String friendUid) async {
    final success = await ref.read(
      blockFriendProvider((uid, friendUid)).future,
    );

    if (!mounted) return;
    _showMessage(context, success ? 'ブロックしました' : 'エラーが発生しました');
  }

  void _unblockUser(BuildContext context, String uid, String friendUid) async {
    final success = await ref.read(
      unblockFriendProvider((uid, friendUid)).future,
    );

    if (!mounted) return;
    _showMessage(context, success ? 'ブロックを解除しました' : 'エラーが発生しました');
  }

  void _showGameInviteDialog(
    BuildContext context,
    String fromUid,
    String toUid,
    String displayName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sumiSurface,
        title: Text('$displayNameを招待'),
        content: const Text('ゲームモードを選択してください'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Friend search dialog
class _FriendSearchDialog extends StatefulWidget {
  final Function(String) onSearch;

  const _FriendSearchDialog({required this.onSearch});

  @override
  State<_FriendSearchDialog> createState() => _FriendSearchDialogState();
}

class _FriendSearchDialogState extends State<_FriendSearchDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.sumiSurface,
      title: const Text('フレンドを検索'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'ユーザー名を入力',
          hintStyle: TextStyle(color: AppColors.washiDim),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.kin),
          ),
        ),
        style: const TextStyle(color: AppColors.washi),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSearch(_controller.text);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
          child: const Text('検索'),
        ),
      ],
    );
  }
}
