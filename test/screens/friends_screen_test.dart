import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/friend_service.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/views/screens/friends_screen.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('FriendsScreen search', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await firestore
          .collection('users')
          .doc(TestData.testUser.uid)
          .set({'displayName': TestData.testUser.displayName});
      await firestore.collection('users').doc('newperson').set({'displayName': 'Newperson'});
      await firestore
          .collection('users')
          .doc('acceptedfriend')
          .set({'displayName': 'Acceptedfriend'});
    });

    ProviderContainer buildContainer() {
      return TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        extraOverrides: [
          friendServiceProvider.overrideWithValue(FriendService(firestore: firestore)),
        ],
      );
    }

    Future<void> openSearchAndQuery(
      WidgetTester tester,
      ProviderContainer container,
      String query,
    ) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(child: const FriendsScreen(), container: container),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), query);
      await tester.tap(find.text('検索'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows an "追加" button for a user with no existing relationship', (tester) async {
      final container = buildContainer();
      await openSearchAndQuery(tester, container, 'Newperson');

      expect(find.text('追加'), findsOneWidget);
    });

    testWidgets('shows "フレンド" instead of "追加" for an already-accepted friend', (tester) async {
      // Reproduces the bug this session fixed: search used to always show
      // "追加" regardless of existing relationship status, so tapping it
      // on an already-accepted friend would silently reset the friendship
      // back to 'pending' (FriendService.addFriend now refuses that, and
      // the UI should never offer the button in the first place here).
      final service = FriendService(firestore: firestore);
      await service.addFriend(currentUid: TestData.testUser.uid, friendUid: 'acceptedfriend');
      await service.acceptFriendRequest(
        currentUid: TestData.testUser.uid,
        friendUid: 'acceptedfriend',
      );

      final container = buildContainer();
      await openSearchAndQuery(tester, container, 'Acceptedfriend');

      // 'フレンド' also appears as the first tab's label, so scope the
      // assertion to the search result row itself.
      expect(
        find.descendant(of: find.byType(ListTile), matching: find.text('フレンド')),
        findsOneWidget,
      );
      expect(find.text('追加'), findsNothing);
    });
  });
}
