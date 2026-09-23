import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/friend_service.dart';

void main() {
  group('FriendService', () {
    late FakeFirebaseFirestore firestore;
    late FriendService service;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = FriendService(firestore: firestore);
      await firestore.collection('users').doc('me').set({'displayName': 'Me'});
      await firestore.collection('users').doc('friend').set({'displayName': 'Friend'});
    });

    test('addFriend creates a pending relationship on both sides when none exists', () async {
      final success = await service.addFriend(currentUid: 'me', friendUid: 'friend');
      expect(success, true);

      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'pending');
      expect(await service.getFriendStatus(currentUid: 'friend', friendUid: 'me'), 'pending');
    });

    test('addFriend is a harmless no-op when already pending', () async {
      await service.addFriend(currentUid: 'me', friendUid: 'friend');
      final success = await service.addFriend(currentUid: 'me', friendUid: 'friend');

      expect(success, true);
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'pending');
    });

    test('addFriend refuses and does not touch an already-accepted friendship', () async {
      await service.addFriend(currentUid: 'me', friendUid: 'friend');
      await service.acceptFriendRequest(currentUid: 'me', friendUid: 'friend');
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'accepted');

      final success = await service.addFriend(currentUid: 'me', friendUid: 'friend');

      expect(success, false);
      // The whole point of this test: re-adding an accepted friend must
      // not silently reset the relationship back to 'pending'.
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'accepted');
      expect(await service.getFriendStatus(currentUid: 'friend', friendUid: 'me'), 'accepted');
    });

    test('addFriend refuses and does not touch a blocked relationship', () async {
      await service.addFriend(currentUid: 'me', friendUid: 'friend');
      await service.blockFriend(currentUid: 'me', friendUid: 'friend');
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'blocked');

      final success = await service.addFriend(currentUid: 'me', friendUid: 'friend');

      expect(success, false);
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), 'blocked');
    });

    test('getFriendStatus returns null when no relationship exists yet', () async {
      expect(await service.getFriendStatus(currentUid: 'me', friendUid: 'friend'), isNull);
    });

    test('isFriend is only true once the relationship is accepted', () async {
      await service.addFriend(currentUid: 'me', friendUid: 'friend');
      expect(await service.isFriend(currentUid: 'me', friendUid: 'friend'), false);

      await service.acceptFriendRequest(currentUid: 'me', friendUid: 'friend');
      expect(await service.isFriend(currentUid: 'me', friendUid: 'friend'), true);
    });
  });
}
