# GoEn バグ修正実装レポート (2026-09-17)

**実装日時**: 2026-09-17  
**コミット**: [09808e5](https://github.com/zka32101/goen/commit/09808e5)

---

## 🔧 実装済み修正

### 1️⃣ Issue: 碁が線上にない (石の座標計算エラー)

**症状**: 石がグリッド交点からズレて描画される

**原因**: `ai_game_screen.dart` の `_buildStones()` メソッドで、石の位置に hardcoded offset を使用
```dart
// 修正前 (❌ hardcoded)
Positioned(
  left: col * cellSize + cellSize / 2 - 14,
  top: row * cellSize + cellSize / 2 - 14,
  child: Container(width: 28, height: 28, ...)
)
```

**修正方法**: cellSize に比例した動的計算を実装
```dart
// 修正後 (✅ proportional)
final stoneRadius = cellSize * 0.4;
Positioned(
  left: col * cellSize + cellSize / 2 - stoneRadius,
  top: row * cellSize + cellSize / 2 - stoneRadius,
  child: Container(
    width: stoneRadius * 2,
    height: stoneRadius * 2,
    ...
  )
)
```

**影響範囲**:
- `_buildStones()` メソッド (line 249-294)
- Legal move indicator (line 225-241)

**検証方法**:
```bash
# ローカルビルド実行
flutter run -d emulator-5554  # 9x9 ボード確認

# 各ボードサイズでテスト
# - 9x9: cellSize = 300 / 9 ≈ 33.3
# - 13x13: cellSize = 300 / 13 ≈ 23.1
# - 19x19: cellSize = 300 / 19 ≈ 15.8
```

---

### 2️⃣ Issue: AI が動かない (Cloud Functions 呼び出し失敗)

**症状**: AI move request がタイムアウトまたは認証エラーで失敗

**原因推定**:
- Firebase google_app_id 未設定 (別途対応)
- Cloud Functions エンドポイント未配置 (別途対応)
- エラーログ不足でトラブルシューティング困難

**修正方法**: 詳細ログ機能を追加
```dart
// 初期化時のログ
GoEngineService() {
  _logger.i('GoEngineService initialized. Region: $_regionDefault');
}

// requestAiMove() の詳細ログ
_logger.d('📡 Attempt ${attempt + 1}/$_maxRetries: Calling requestAiMove...');
_logger.d('✓ Cloud Functions callable initialized');
_logger.d('📦 Payload prepared: ${payload.keys.toList()}');

// 成功時
_logger.i('✅ AI move received: row=${result.data['row']}, col=${result.data['col']}');

// エラー時
_logger.e('❌ Cloud Function error');
_logger.e('  Code: ${e.code}');
_logger.e('  Message: ${e.message}');
_logger.e('  Details: ${e.details}');
```

**影響範囲**:
- `GoEngineService.__init__()` - 初期化ログ追加
- `requestAiMove()` (line 121-180) - 詳細ログ強化
- `judgeGameEnd()` (line 194-247) - 詳細ログ強化

**次のステップ** (別セッションで実行):
1. Firebase Console で `google_app_id` を確認・再設定
2. Cloud Functions デプロイメント状態確認
3. ログを `flutter logs` で確認し、エラーコードを特定

---

### 3️⃣ Issue: UI デザインを和風に (日本的美学の統合)

**症状**: UIが汎用的で日本文化の要素が不足

**実装内容**:

#### 📦 依存関係追加
```yaml
# pubspec.yaml
google_fonts: ^6.1.0  # 日本語セリフフォント対応
```

#### 🎨 色パレット強化 (theme.dart)
```dart
class AppColors {
  // 墨色 (sumi-iro) - Japanese ink black
  static const Color primary = Color(0xFF2B2B2B);
  
  // 金 (kin) - Gold accent
  static const Color accent = Color(0xFFD4AF37);
  
  // 竹色 (takeniro) - Bamboo green
  static const Color bambooGreen = Color(0xFF008000);
  
  // 和紙 (washi) - Warm white paper
  static const Color white = Color(0xFFFFFBF0);
}
```

#### 📝 フォント設定 (Noto Serif JP)
```dart
textTheme: TextTheme(
  displayLarge: GoogleFonts.notoSerifJp(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),
  // ... (他のスタイルも適用)
)

appBarTheme: AppBarTheme(
  titleTextStyle: GoogleFonts.notoSerifJp(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  ),
)
```

**影響範囲**:
- `pubspec.yaml` - Google Fonts 追加
- `lib/config/theme.dart`:
  - `AppColors` クラス - 日本色パレット強化
  - `darkTheme` の `textTheme` と `appBarTheme` - セリフフォント適用
  - `lightTheme` の `textTheme` - セリフフォント適用

**Design Elements** (将来の拡張):
- ✅ 色: 墨・金・竹 (実装済み)
- 📋 書体: Noto Serif JP (実装済み)
- 🔄 パターン: 矢絣・唐草模様 (将来実装)
- 📊 背景: 和紙テクスチャ (将来実装)

---

## 📊 変更サマリー

| ファイル | 変更行数 | 内容 |
|---------|---------|------|
| `ai_game_screen.dart` | +6, -6 | 石の座標計算を比例計算に修正 |
| `go_engine_service.dart` | +43, -21 | Firebase ログ機能を強化 |
| `theme.dart` | +29, -19 | 日本風色・フォント実装 |
| `pubspec.yaml` | +1 | google_fonts 依存関係追加 |

**合計**: 4 ファイル変更、+79 行追加、-46 行削除

---

## ✅ テスト実行手順

### 1. 石の座標計算確認
```bash
# ボードが正しく描画されることを確認
flutter run -d emulator-5554
# → 石がグリッド交点に整列していることを確認
```

### 2. ログ出力確認
```bash
# Cloud Functions 呼び出しログを確認
flutter logs
# → 以下のログが表示されることを確認
# 🎯 Requesting AI move
# 📡 Attempt 1/2
# ✓ Cloud Functions callable initialized
```

### 3. 日本風 UI 確認
```bash
# フォントが正しく表示されることを確認
flutter run -d emulator-5554
# → タイトル・ボタンが Noto Serif JP で表示されることを確認
# → 色が墨色・金・竹色で表示されることを確認
```

---

## 🔍 次のセッション TODO

### P1 (ブロッカー)
- [ ] Firebase `google_app_id` 再設定
  - Firebase Console で `google-services.json` を再確認
  - `flutter pub get` でファイル再同期
- [ ] Cloud Functions デプロイ確認
  - `requestAiMove` エンドポイント確認
  - `judgeGameEnd` エンドポイント確認

### P2 (テスト・検証)
- [ ] UI テスト実行 (9x9, 13x13, 19x19 ボード)
- [ ] Cloud Functions 呼び出しテスト (ログ確認)
- [ ] 日本風デザインの視覚的確認

### P3 (ポーランド)
- [ ] 背景テクスチャ (和紙) 実装
- [ ] 装飾パターン (矢絣・唐草) 実装
- [ ] Google Play Console 準備

---

## 📝 参考リンク

- [BUGFIX_2026_09_17.md](./BUGFIX_2026_09_17.md) - 診断レポート
- [SESSION_HANDOFF_2026_09_17.md](./SESSION_HANDOFF_2026_09_17.md) - セッション引継ぎ
- [FLUTTER_BUILD_GUIDE.md](./FLUTTER_BUILD_GUIDE.md) - ビルド手順書

---

**Status**: ✅ P1 修正実装完了、P2 検証待ち
