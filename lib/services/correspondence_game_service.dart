import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goen/models/index.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// CorrespondenceGameService - 長時間ゲーム管理 (Phase 58 - WIP)
class CorrespondenceGameService {
  final FirebaseFirestore _firestore;

  CorrespondenceGameService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Placeholder for Phase 58 correspondence game implementation
  Future<void> placeholder() async {
    _logger.i('Correspondence game service - Phase 58 WIP');
  }
}
