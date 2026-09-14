import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../widgets/index.dart';

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
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('フレンド'),
        backgroundColor: Colors.grey[900],
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
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Text('ログインしてください'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsList(user.uid),
              _buildPendingRequests(user.uid),
              _buildBlockedUsers(user.uid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchDialog(context),
        backgroundColor: Colors.amber[700],
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
                style: TextStyle(color: Colors.grey[400])),
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
      color: Colors.amber[900]?.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber[700],
              radius: 24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'リクエスト待機中',
                    style: TextStyle(color: Colors.amber[600], fontSize: 12),
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
                backgroundColor: Colors.green[700],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _blockFriend(context, uid, request.uid),
              icon: const Icon(Icons.close),
              label: const Text('拒否'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
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
                style: TextStyle(color: Colors.grey[400])),
          );
        }

        return ListView.builder(
          itemCount: blocked.length,
          itemBuilder: (context, index) {
            final user = blocked[index];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red[700],
                      radius: 24,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          _unblockUser(context, uid, user.uid),
                      child: const Text('ブロック解除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[400],
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
      backgroundColor: Colors.grey[900],
      builder: (context) {
        final resultsAsync = ref.watch(searchUsersProvider(query));

        return resultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return Center(
                child: Text('ユーザーが見つかりません',
                    style: TextStyle(color: Colors.grey[400])),
              );
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final user = results[index];
                return ListTile(
                  title: Text(user.displayName,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${user.totalGamesPlayed} games',
                      style: TextStyle(color: Colors.grey[400])),
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
    final currentUser = ref.read(currentUserProvider);
    currentUser.whenData((user) async {
      if (user != null) {
        final success = await ref.read(
          addFriendProvider((user.uid, friendUid, null)).future,
        );

        if (!mounted) return;
        _showMessage(context,
            success ? 'リクエストを送信しました' : 'エラーが発生しました');
        if (success) Navigator.pop(context);
      }
    });
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
    // TODO: Implement unblock functionality in FriendService
    _showMessage(context, 'ブロック解除機能は準備中です');
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
        backgroundColor: Colors.grey[900],
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
      backgroundColor: Colors.grey[900],
      title: const Text('フレンドを検索'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'ユーザー名を入力',
          hintStyle: TextStyle(color: Colors.grey[500]),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.amber[700]!),
          ),
        ),
        style: const TextStyle(color: Colors.white),
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
          child: const Text('検索'),
        ),
      ],
    );
  }
}
