import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
// `Friend` is ambiguous through models/index.dart (see playstyle_service.dart);
// import the specific model files instead.
import '../models/friend.dart';
import '../models/playstyle.dart';
import '../services/index.dart';

final _logger = Logger();

final playstyleServiceProvider = Provider((ref) {
  return PlaystyleService(FirebaseFirestore.instance);
});

final playstyleProfileProvider =
    FutureProvider.family<PlaystyleProfile, String>((ref, uid) async {
  final service = ref.watch(playstyleServiceProvider);
  try {
    final profile = await service.getProfile(uid);
    return profile;
  } catch (e) {
    _logger.e('Error fetching playstyle profile: $e');
    rethrow;
  }
});

final compatibleFriendsProvider =
    FutureProvider.family<List<PlaystyleCompatibility>, ({String uid, List<Friend> friends})>(
        (ref, params) async {
  final service = ref.watch(playstyleServiceProvider);
  try {
    final results = await service.getCompatibleFriends(
      uid: params.uid,
      friends: params.friends,
    );
    _logger.i('Fetched ${results.length} compatibility scores for ${params.uid}');
    return results;
  } catch (e) {
    _logger.e('Error fetching compatible friends: $e');
    rethrow;
  }
});

final computePlaystyleProfileProvider = Provider((ref) {
  return (String uid) async {
    final service = ref.watch(playstyleServiceProvider);
    try {
      final profile = await service.computeAndSaveProfile(uid);
      _logger.i('Computed and saved playstyle profile for $uid');
      return profile;
    } catch (e) {
      _logger.e('Error computing playstyle profile: $e');
      rethrow;
    }
  };
});
