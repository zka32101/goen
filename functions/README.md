# GoEn Cloud Functions

`generateGameAnalysis` — 対局終了後の「AIで振り返る」機能（`GameResultScreen`）が
呼ぶ、唯一実際に使われている Cloud Function。Anthropic API (Claude) を使って
対局の解説を生成し、`GameAnalysis`（`lib/services/ai_explanation_service.dart`）
と同じ JSON 形式で返す。

このリポジトリにはまだ `functions/` の実デプロイ実績がない（このセッションで
初めて作成した）。以下は実際にデプロイする開発者向けの手順。

## 前提

- Node.js 20（`package.json` の `engines.node` と合わせる。ローカルの node
  バージョンが違っても、実際にデプロイされる Cloud Functions のランタイムは
  Node 20 になる）
- Firebase CLI (`npm install -g firebase-tools`)、対象プロジェクトへの
  デプロイ権限
- Anthropic API キー（[console.anthropic.com](https://console.anthropic.com/)）

## セットアップ

```bash
cd functions
npm install
```

## Anthropic API キーの設定（Secret Manager 経由）

コードは `defineSecret("ANTHROPIC_API_KEY")` で読み込む。`.env` ファイルや
`firebase functions:config:set`（レガシー方式）ではなく、Secret Manager に
保存する:

```bash
firebase functions:secrets:set ANTHROPIC_API_KEY
# プロンプトが出たらAPIキーを貼り付ける
```

## ローカルでの動作確認（エミュレータ）

```bash
npm run build
firebase emulators:start --only functions
```

エミュレータ実行時も Secret の値を読ませるには `.secret.local` に
`ANTHROPIC_API_KEY=sk-ant-...` を1行書いておく（`.gitignore` 済み、
絶対にコミットしないこと）。

## デプロイ

```bash
firebase deploy --only functions
```

初回デプロイ時、Firebase が Cloud Functions / Cloud Build / Artifact
Registry など必要な API の有効化を求めてくることがある（コンソールの案内に
従う）。

## 動作確認

デプロイ後、アプリの `GameResultScreen` で対局を1局保存し「AIで振り返る」を
押して解説が返ってくることを確認する。失敗した場合は:

```bash
firebase functions:log
```

でログを確認する（`generateGameAnalysis` 内の `logger.error` 呼び出しが
Anthropic API 呼び出し失敗時とレスポンス形式不正時の両方をログに残す）。

## 既知の制約 / 未実装

- `lib/services/ai_explanation_service.dart` は `generateMoveExplanation`
  （1手ごとのその場解説）と `generateQuickMoveComment`（対局中のクイック
  コメント）という2つの Cloud Function 呼び出しも宣言しているが、アプリの
  どの画面からも呼ばれていない（`GameResultScreen` が使うのは
  `generateGameAnalysis` のみ）。呼び出し元が実際にできてから実装する。
- 1局あたり最大 `MAX_MOVES_TO_EXPLAIN`（10手）までしか解説を生成しない
  （19路盤で200手を超える対局を全て解説すると応答サイズ・レイテンシ・
  コストが膨らみすぎるため）。AIに「特に重要だった局面」を選ばせている。
- レシート検証や課金プランによる呼び出し制限は無い（`request.auth` の
  有無しかチェックしていない）。将来的にサブスク会員限定機能にする場合は
  ここに `users/{uid}.subscriptionActive` のチェックを足す必要がある。
