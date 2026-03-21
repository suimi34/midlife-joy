# プロジェクト指示（Claude Code）

Cursor / Claude Code / 人間が共通で参照するドキュメントの置き場所を次のようにする。

## 必ず参照する場所

### 1. `docs/`（コーディング規約・手順の正本）

作業内容に該当するトピックがあるときは、**実装前に `docs/` 内の該当ファイルを読む**。

| ドキュメント                                                 | 用途                                                                                      |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| [docs/frontend-conventions.md](docs/frontend-conventions.md) | フロント（React / TypeScript / Inertia / Tailwind / `app/javascript` 構成・npm コマンド） |
| [docs/README.md](docs/README.md)                             | `docs/` 配下の索引                                                                        |

今後、バックエンドやデプロイなどのガイドを `docs/` に追加する場合も、同様にここを正本とする。

### 2. `.claude/rules/specification.md`（プロダクト仕様）

機能スコープ・UX・文言などアプリとしての要件はこちら。コードスタイルは `docs/` を優先する。

### 3. `.claude/docs/`（補助）

MVP 計画など。仕様の詳細は `specification.md` と整合させる。

## 作業時の方針

- フロント変更では `docs/frontend-conventions.md` のディレクトリ・import・Tailwind・ツール指示に従う。
- 仕様（`.claude/rules/specification.md`）と `docs/` の規約がぶつかる場合は、ユーザーに確認するか、規約側の更新を提案する。
