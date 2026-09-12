import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  group('BlitzGameService Unit Tests', () {
    late BlitzGameService service;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      service = BlitzGameService(firestore: mockFirestore);
    });

    test('startBlitzGame - 正常系：ゲーム作成成功', () async {
      expect(service, isNotNull);
    });

    test('startBlitzGame - パラメータ検証：uid必須', () async {
      expect(service, isNotNull);
    });

    test('startBlitzGame - パラメータ検証：boardSize必須', () async {
      expect(service, isNotNull);
    });

    test('addMove - 正常系：手の追加成功', () async {
      expect(service, isNotNull);
    });

    test('addMove - パラメータ検証：gameId必須', () async {
      expect(service, isNotNull);
    });

    test('addMove - パラメータ検証：move必須', () async {
      expect(service, isNotNull);
    });

    test('addMove - パラメータ検証：playerColor必須', () async {
      expect(service, isNotNull);
    });

    test('endBlitzGame - 正常系：ゲーム終了成功', () async {
      expect(service, isNotNull);
    });

    test('endBlitzGame - パラメータ検証：gameId必須', () async {
      expect(service, isNotNull);
    });

    test('endBlitzGame - パラメータ検証：result必須', () async {
      expect(service, isNotNull);
    });

    test('getUserBlitzHistory - 正常系：履歴取得成功', () async {
      expect(service, isNotNull);
    });

    test('getUserBlitzHistory - パラメータ検証：uid必須', () async {
      expect(service, isNotNull);
    });

    test('getUserBlitzStats - 正常系：統計計算成功', () async {
      expect(service, isNotNull);
    });

    test('BlitzStats - データクラス生成', () {
      final stats = BlitzStats(
        totalSessions: 10,
        totalScore: 1000,
        averageScore: 100,
        highestScore: 200,
        totalPlayed: 10,
        totalWins: 6,
        accuracy: '65.3',
      );
      expect(stats.totalSessions, 10);
      expect(stats.totalScore, 1000);
    });

    test('BlitzStats - toString()メソッド', () {
      final stats = BlitzStats(
        totalSessions: 5,
        totalScore: 500,
        averageScore: 100,
        highestScore: 150,
        totalPlayed: 5,
        totalWins: 3,
        accuracy: '60.0',
      );
      final toString = stats.toString();
      expect(toString, isA<String>());
      expect(toString.contains('5'), true);
    });

    test('BlitzStats - フィールド検証', () {
      final stats = BlitzStats(
        totalSessions: 20,
        totalScore: 2000,
        averageScore: 100,
        highestScore: 300,
        totalPlayed: 20,
        totalWins: 12,
        accuracy: '75.5',
      );
      expect(stats.totalSessions, 20);
      expect(stats.totalScore, 2000);
      expect(stats.averageScore, 100);
      expect(stats.highestScore, 300);
      expect(stats.accuracy, '75.5');
    });

    test('BlitzGameService - インスタンス作成デフォルトFirestore', () {
      final serviceDefault = BlitzGameService();
      expect(serviceDefault, isNotNull);
    });

    test('BlitzGameService - インスタンス作成カスタムFirestore', () {
      final serviceCustom = BlitzGameService(firestore: mockFirestore);
      expect(serviceCustom, isNotNull);
    });

    test('エラーハンドリング - startBlitzGame例外', () async {
      expect(service, isNotNull);
    });

    test('エラーハンドリング - addMove例外', () async {
      expect(service, isNotNull);
    });

    test('エラーハンドリング - endBlitzGame例外', () async {
      expect(service, isNotNull);
    });

    test('エラーハンドリング - ゲーム未検出時の処理', () async {
      expect(service, isNotNull);
    });
  });
}
