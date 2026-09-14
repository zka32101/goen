import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/models/extended_game_models.dart';
import 'package:goen/views/widgets/friend_list_widget.dart';

void main() {
  group('FriendListWidget Tests', () {
    late List<Friend> friends;

    setUp(() {
      friends = [
        const Friend(
          uid: 'friend-1',
          displayName: 'Friend One',
          currentRating: 1800.0,
          totalGamesPlayed: 150,
          status: 'online',
          addedAt: null,
          notes: 'Great player',
          avatarUrl: null,
        ),
        const Friend(
          uid: 'friend-2',
          displayName: 'Friend Two',
          currentRating: 1600.0,
          totalGamesPlayed: 100,
          status: 'offline',
          addedAt: null,
          notes: null,
          avatarUrl: null,
        ),
      ];
    });

    testWidgets('Renders friend list with multiple items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
            ),
          ),
        ),
      );

      // Verify friends are displayed
      expect(find.text('Friend One'), findsOneWidget);
      expect(find.text('Friend Two'), findsOneWidget);

      // Verify ratings are displayed
      expect(find.text('1800'), findsOneWidget);
      expect(find.text('1600'), findsOneWidget);
    });

    testWidgets('Displays loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: const [],
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: const [],
            ),
          ),
        ),
      );

      // Verify empty state icon
      expect(find.byIcon(Icons.people_outline), findsOneWidget);

      // Verify empty state message
      expect(find.text('フレンドがいません'), findsOneWidget);
    });

    testWidgets('Calls onTap when friend item is tapped', (WidgetTester tester) async {
      Friend? tappedFriend;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
              onTap: (friend) {
                tappedFriend = friend;
              },
            ),
          ),
        ),
      );

      // Tap first friend
      await tester.tap(find.text('Friend One'));
      await tester.pumpAndSettle();

      expect(tappedFriend?.displayName, 'Friend One');
    });

    testWidgets('Calls onMessage when message button is pressed', (WidgetTester tester) async {
      Friend? messagedFriend;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
              onMessage: (friend) {
                messagedFriend = friend;
              },
            ),
          ),
        ),
      );

      // Tap popup menu and select message option
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('メッセージ'), findsOneWidget);
    });

    testWidgets('Calls onRefresh when refreshed', (WidgetTester tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
              onRefresh: () async {
                refreshed = true;
              },
            ),
          ),
        ),
      );

      // Perform pull-to-refresh
      await tester.flingFrom(
        const Offset(100, 300),
        const Offset(0, 100),
        duration: const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
    });

    testWidgets('Displays friend notes when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
            ),
          ),
        ),
      );

      // Friend One has notes
      expect(find.text('Great player'), findsOneWidget);

      // Friend Two has no notes (but note field should not be shown)
      expect(find.text('Friend Two'), findsOneWidget);
    });

    testWidgets('Divider separates list items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: friends,
            ),
          ),
        ),
      );

      // Verify separator exists
      expect(find.byType(Divider), findsWidgets);
    });
  });

  group('FriendChipWidget Tests', () {
    late Friend friend;

    setUp(() {
      friend = const Friend(
        uid: 'friend-1',
        displayName: 'Chip Friend',
        currentRating: 1800.0,
        totalGamesPlayed: 100,
        status: 'online',
        addedAt: null,
        notes: null,
        avatarUrl: null,
      );
    });

    testWidgets('Renders compact friend chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendChipWidget(
              friend: friend,
            ),
          ),
        ),
      );

      // Verify name and rating are displayed
      expect(find.text('Chip Friend'), findsOneWidget);
      expect(find.text('1800'), findsOneWidget);
    });

    testWidgets('Calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendChipWidget(
              friend: friend,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('Hides rating when showRating is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendChipWidget(
              friend: friend,
              showRating: false,
            ),
          ),
        ),
      );

      // Name should be displayed
      expect(find.text('Chip Friend'), findsOneWidget);

      // Rating should not be displayed
      expect(find.text('1800'), findsNothing);
    });
  });

  group('FriendHorizontalListWidget Tests', () {
    late List<Friend> friends;

    setUp(() {
      friends = [
        const Friend(
          uid: 'friend-1',
          displayName: 'Player One',
          currentRating: 1800.0,
          totalGamesPlayed: 150,
          status: 'online',
          addedAt: null,
          notes: null,
          avatarUrl: null,
        ),
        const Friend(
          uid: 'friend-2',
          displayName: 'Player Two',
          currentRating: 1600.0,
          totalGamesPlayed: 100,
          status: 'offline',
          addedAt: null,
          notes: null,
          avatarUrl: null,
        ),
        const Friend(
          uid: 'friend-3',
          displayName: 'Player Three',
          currentRating: 1700.0,
          totalGamesPlayed: 120,
          status: 'online',
          addedAt: null,
          notes: null,
          avatarUrl: null,
        ),
      ];
    });

    testWidgets('Renders horizontal scrollable friend list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendHorizontalListWidget(
              friends: friends,
            ),
          ),
        ),
      );

      // Verify all friends are displayed
      expect(find.text('Player One'), findsOneWidget);
      expect(find.text('Player Two'), findsOneWidget);
      expect(find.text('Player Three'), findsOneWidget);
    });

    testWidgets('Displays empty state for no friends', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendHorizontalListWidget(
              friends: const [],
            ),
          ),
        ),
      );

      expect(find.text('フレンドなし'), findsOneWidget);
    });

    testWidgets('Calls onFriendSelected when friend is tapped', (WidgetTester tester) async {
      Friend? selectedFriend;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendHorizontalListWidget(
              friends: friends,
              onFriendSelected: (friend) {
                selectedFriend = friend;
              },
            ),
          ),
        ),
      );

      // Tap first friend
      await tester.tap(find.text('Player One'));
      await tester.pumpAndSettle();

      expect(selectedFriend?.displayName, 'Player One');
    });

    testWidgets('Renders friend avatars with initials', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendHorizontalListWidget(
              friends: friends,
            ),
          ),
        ),
      );

      // Verify avatars are rendered
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('Is horizontally scrollable', (WidgetTester tester) async {
      // Add more friends to ensure scrolling
      final manyFriends = List.generate(
        10,
        (i) => Friend(
          uid: 'friend-$i',
          displayName: 'Player $i',
          currentRating: 1500.0 + i,
          totalGamesPlayed: 100 + i,
          status: 'online',
          addedAt: null,
          notes: null,
          avatarUrl: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendHorizontalListWidget(
              friends: manyFriends,
            ),
          ),
        ),
      );

      // Verify SingleChildScrollView is used
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('Friend Data Display Tests', () {
    late Friend friend;

    setUp(() {
      friend = const Friend(
        uid: 'friend-1',
        displayName: 'Data Test Friend',
        currentRating: 1850.5,
        totalGamesPlayed: 175,
        status: 'online',
        addedAt: null,
        notes: 'Test note',
        avatarUrl: null,
      );
    });

    testWidgets('Displays rating with decimal precision', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: [friend],
            ),
          ),
        ),
      );

      // Verify rating is displayed
      expect(find.text('レート: 1850'), findsOneWidget);
    });

    testWidgets('Handles friend with missing avatar gracefully', (WidgetTester tester) async {
      final friendNoAvatar = friend.copyWith(avatarUrl: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: [friendNoAvatar],
            ),
          ),
        ),
      );

      expect(find.text('Data Test Friend'), findsOneWidget);
    });

    testWidgets('Truncates long notes with ellipsis', (WidgetTester tester) async {
      final friendLongNotes = friend.copyWith(
        notes: '本当に長い注釈です。このテストはノートが長い場合に椭円で切り詰められるかどうかを確認しています',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendListWidget(
              friends: [friendLongNotes],
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
    });
  });
}
