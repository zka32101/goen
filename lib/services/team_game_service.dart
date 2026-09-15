import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goen/models/index.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// TeamGameService - チームゲーム対局管理 (Phase 58 - WIP)
class TeamGameService {
  final FirebaseFirestore _firestore;

  TeamGameService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Placeholder for Phase 58 team game implementation
  Future<void> placeholder() async {
    _logger.i('Team game service - Phase 58 WIP');
  }
}
