# フロントエンドコーディング規約（midlife-joy）

## スタック

- React 19 + TypeScript（Vite 7）
- Inertia.js（`@inertiajs/react`）
- Tailwind CSS v4（`@tailwindcss/vite`、テーマは `app/javascript/entrypoints/application.css` の `@theme`）

## ディレクトリ

| パス                          | 役割                                              |
| ----------------------------- | ------------------------------------------------- |
| `app/javascript/entrypoints/` | Vite エントリ（`inertia.tsx`、`application.css`） |
| `app/javascript/pages/`       | Inertia ページ（ルートごとに 1 コンポーネント）   |
| `app/javascript/components/`  | 共有 UI コンポーネント                            |
| `app/javascript/lib/`         | 外部 SDK ラップなど（例: Firebase）               |
| `app/javascript/types/`       | 共有型・定数（Inertia の props 型など）           |

## import とパス

- エイリアス **`@/`** を優先（`app/javascript` ルート）。`~/*` は歴史的互換として残っているが、新規コードは `@/` に統一する。

## React / TypeScript

- **文末セミコロンは必須**（Prettier の `semi: true` で統一）。
- ページ・コンポーネントは **デフォルト export** の関数コンポーネント。
- Props 型は `type Props = { ... }` またはインライン。可能なら `types/` の共有型を再利用。
- `strict` 相当の TS 設定に従う（未使用変数はコンパイルエラー）。

## スタイル（Tailwind）

- **ユーティリティファースト**。カスタム CSS はテーマトークンや `@theme` の拡張に限定。
- 色・意味付きクラスは既存トークンを優先: `text-text`, `text-muted`, `bg-bg`, `border-accent` など（`application.css` を参照）。

## Inertia

- フォームは `useForm`、フラッシュ・`current_user` など共有データの型は `types/index.ts` の `SharedProps` 等に集約。

## ツール

- **フォーマット**: Prettier（`npm run format` / `npm run format:check`）
- **リント**: ESLint（`npm run lint`）
- **型チェック**: `npm run check`（`tsc`）

コミット前に `npm run check` と `npm run lint` が通るようにする。

## 関連

- 他のガイドの索引: [docs/README.md](README.md)
- プロダクト仕様: [`.claude/rules/specification.md`](../.claude/rules/specification.md)
