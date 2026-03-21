---
name: public-repo-push-check
description: Audits a codebase and git state before pushing to a public repository for accidental secrets, credentials, private data, and policy issues. Use when open-sourcing a project, before the first public push, or when the user asks whether code is safe to publish publicly.
---

# 公開リポジトリへプッシュ前チェック

## 目的

ソースを**公開リポジトリ**に出す前に、漏洩・コンプライアンス・運用リスクを洗い出す。修正はユーザー判断；エージェントは**検出と優先度付き報告**を行う。

## 手順（短い順）

1. **今回プッシュ対象の範囲**を把握（ブランチ・コミット範囲・初回公開か追加分か）。
2. 下記チェックリストを**リポジトリルートから**実行（`rg` / `git` / ファイル一覧）。
3. 見つかった項目を **重大度順**（Critical → High → Medium → Low）で列挙し、**ファイルパスと根拠**を付ける。
4. **履歴に残っている秘密**の可能性がある場合は「履歴スクラブ or 新規履歴で作り直し」を明示する。

## チェックリスト（必須）

### Critical（公開前に必ず確認）

- [ ] **秘密情報のコミット有無**: API キー、Bearer/JWT、パスワード、プライベートキー（`BEGIN` … `PRIVATE KEY`）、`RAILS_MASTER_KEY`、DB URL にパスワード、OAuth client secret。
- [ ] **平文の認証情報ファイル**: `.env`、`.env.*`（`.env.example` はプレースホルダのみか）、`*.pem`、`id_rsa`、`credentials`（復号キーとセットでないか）、`config/master.key` がトラックされていないか。
- [ ] **暗号化 credentials が意図通りか**: `*.yml.enc` はコミット可だが **`master.key` / 本番キーがリポジトリに無い**こと。
- [ ] **git に載っているか**: `git ls-files` と `git log -p -S`（既知パターン）で過去コミットを疑う。

### High

- [ ] **`.gitignore` / `.dockerignore`**: 秘密・ビルド成果物・ローカル DB ダンプが除外されているか。
- [ ] **ハードコードされた本番 URL / 内部ホスト名 / 社内メール**がソース・コメント・設定にないか。
- [ ] **Firebase / S3 / Stripe 等の公開キー**: Web 用は多く公開前提だが、**サーバー専用シークレット**がフロントに埋め込まれていないか（Vite `import.meta.env` のビルド結果も含む）。
- [ ] **テスト・フィクスチャ・シード**に実在するメール・電話・個人情報がないか。

### Medium

- [ ] **ライセンス**: ルートに `LICENSE`（または意図したライセンス表記）があるか。依存ライブラリの再配布条件と矛盾しないか。
- [ ] **TODO/FIXME に社内情報**がないか。
- [ ] **デバッグ用ルート・バックドア・認証バイパス**が本番向けコードに残っていないか。

### Low

- [ ] **巨大バイナリ・誤コミット**（意図しない `node_modules`、ダンプ、秘密はないがサイズだけ大きいファイル）。
- [ ] **サブモジュール / サブツリー**がプライベート参照を指していないか。

## 推奨コマンド例（読み取り専用）

リポジトリルートで実行。ヒットは**必ず文脈を確認**（プレースホルダか本物か）。

```bash
# トラックされているファイル一覧（秘密ファイルが含まれていないか）
git ls-files | rg -i 'env$|\.pem$|master\.key$|id_rsa|credentials\.json|\.pfx$' || true

# よくある秘密パターン（誤検知に注意）
git grep -n -E 'AKIA[0-9A-Z]{16}|sk_live_|sk_test_|ghp_[a-zA-Z0-9]{36}|xox[baprs]-' || true

# 最近の差分のみ確認する場合
git diff origin/main...HEAD
```

履歴が既にリモートにあった後で秘密をコミットした場合は、`git log` だけでは足りない。**履歴から完全除去**または**新リポジトリで履歴なし**を推奨する。

## 報告フォーマット

1. **結論**: このまま公開プッシュしてよいか（Yes / No / 条件付き）。
2. **Critical / High の一覧**: パス、抜粋（秘密値はマスク）、推奨対応。
3. **履歴リスク**: あり / なし、確認方法。
4. **任意**: Medium / Low。

## 注意

- 検出ツールの**偽陽性**（例: ドキュメント内の `sk_test_` 説明文）を区別する。
- ユーザーが「問題なし」と言っても **Critical が1つでも残る場合は「プッシュ非推奨」**と明記する。

## 追加リソース

- プロジェクト固有の除外ルールや「公開してよいファイル」があれば、リポジトリの `CONTRIBUTING.md` や社内ドキュメントを参照する（存在する場合）。
