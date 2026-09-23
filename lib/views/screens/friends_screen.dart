import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../widgets/index.dart';
import 'friend_profile_screen.dart';
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
            _openFriendProfile(context, uid, friend);
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
    final blockedFuture = ref.watch(blockedFriendsProvider(uid));

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
      builder: (dialogContext) => _FriendSearchDialog(
        onSearch: (query) {
          // dialogContextはこのダイアログ自身のルートに属しており、
          // Navigator.popで閉じ始めた直後にそれを使ってshowModalBottomSheet
          // を呼ぶと（popされつつあるルートのcontextなので）シートが実際には
          // 表示されない。結果ボトムシートはFriendsScreen自身の（長生きする）
          // contextに紐付ける。
          Navigator.pop(dialogContext);
          _searchFriends(context, query);
        },
      ),
    );
  }

  void _searchFriends(BuildContext context, String query) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    final uid = currentUser.uid;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sumiSurface,
      builder: (sheetContext) {
        // Consumerでラップしないと、ref.watch()の購読先がこのシート自身
        // ではなくFriendsScreen自身のElementに紐付いてしまう
        // （showModalBottomSheetのbuilderはFriendsScreenのbuild()とは
        // 別のツリーで、しかも一度しか呼ばれない）。その結果、
        // searchUsersProvider/friendStatusProviderが後から解決しても
        // このシートは再ビルドされず、ローディング表示のまま固まって
        // 検索結果が永遠に表示されない。
        return Consumer(
          builder: (context, ref, child) {
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
                      trailing: _buildAddFriendAction(context, ref, uid, user.uid),
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
      },
    );
  }

  /// フレンド候補の既存関係の状態に応じて表示を変える。すでにaccepted/
  /// blockedの相手に「追加」を出すと、再タップでFriendService.addFriendの
  /// ガードに引っかかり無反応に見えるだけで終わってしまうため、状態を
  /// 見て事前にラベルを変えておく（ガード自体はサービス層にもあるので
  /// 二重の安全策）。
  Widget _buildAddFriendAction(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String targetUid,
  ) {
    final statusAsync = ref.watch(friendStatusProvider((uid, targetUid)));

    return statusAsync.when(
      data: (status) {
        switch (status) {
          case 'accepted':
            return Text('フレンド', style: TextStyle(color: AppColors.washiDim));
          case 'pending':
            return Text('申請中', style: TextStyle(color: AppColors.washiDim));
          case 'blocked':
            return Text('ブロック中', style: TextStyle(color: AppColors.washiDim));
          default:
            return ElevatedButton(
              onPressed: () => _addFriend(context, targetUid),
              child: const Text('追加'),
            );
        }
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, stack) => ElevatedButton(
        onPressed: () => _addFriend(context, targetUid),
        child: const Text('追加'),
      ),
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
        _openFriendProfile(context, uid, friend);
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

    if (success) {
      ref.invalidate(friendStatusProvider((currentUser.uid, friendUid)));
    }
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

    if (success) {
      ref.invalidate(blockedFriendsProvider(uid));
      // Also refreshes the "招待待ち" tab when 拒否 (decline) calls this -
      // the pending request just got blocked and should disappear from
      // that list without waiting for a manual refresh.
      ref.invalidate(pendingFriendRequestsProvider(uid));
    }
    if (!mounted) return;
    _showMessage(context, success ? 'ブロックしました' : 'エラーが発生しました');
  }

  void _unblockUser(BuildContext context, String uid, String friendUid) async {
    final success = await ref.read(
      unblockFriendProvider((uid, friendUid)).future,
    );

    if (success) {
      ref.invalidate(blockedFriendsProvider(uid));
    }
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

  void _openFriendProfile(BuildContext context, String uid, Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfileScreen(
          currentUid: uid,
          friend: friend,
          onInvite: () => _showGameInviteDialog(context, uid, friend.uid, friend.displayName),
        ),
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
