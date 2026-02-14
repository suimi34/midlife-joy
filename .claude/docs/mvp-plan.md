# MVP実装プラン: 今夜の至福

## Context

仕様書 `.claude/rules/specification.md` に基づき、「今夜の至福」のMVPを実装する。
既存SNSの承認欲求・比較文化を排除し、「静かな時間を肯定する」サービスを構築する。

---

## 技術スタック

| レイヤー  | 技術                                                      |
| --------- | --------------------------------------------------------- |
| Backend   | Rails 8.1.2, MySQL 5.7, Puma                              |
| Frontend  | React 19, Inertia.js v2, TypeScript                       |
| Bundler   | Vite v7 (`vite_rails`)                                    |
| CSS       | Tailwind CSS v4                                           |
| Auth      | Firebase Authentication (client) → Rails session (server) |
| Image     | Active Storage (local disk)                               |
| Token検証 | `jwt` gem + Rails.cache で証明書キャッシュ                |
| 開発環境  | Docker Compose                                            |

---

## MVPスコープ

**含む:**

- ユーザー認証（Firebase Auth → Rails session）
- 投稿（一行テキスト20文字 + 写真1枚任意）
- フィード表示（最大10件、時間帯フィルタ 18:00〜翌3:00）
- リアクション（「渋い」のみ）
- ダークUI（仕様書カラーパレット準拠）

**含まない（次フェーズ）:**

- コーヒー固有フィールド（豆・器具・湯温・挽き目）
- PWA対応
- プッシュ通知
- ユーザープロフィール編集

---

## 実装ステップ

### Step 1: フロントエンド基盤の切り替え [完了 ✅]

**目的:** Importmap + Hotwire → Vite + Inertia + React + Tailwind に移行

**実施済み内容:**

- `importmap-rails`, `turbo-rails`, `stimulus-rails` を削除
- `inertia_rails` (~> 3.17), `vite_rails`, `jwt` を追加
- `bin/rails generate inertia:install` 実行（React + TypeScript + Tailwind 選択）
- 旧Hotwire関連ファイル削除（controllers/, importmap.rb, application.js）
- レイアウトをVite/Inertiaタグに置き換え
- Dockerfile に Node.js 22 + npm ci + foreman 追加
- compose.yml にViteポート(3036)公開、起動コマンド調整
- Procfile.dev で Vite devサーバー + Rails を並列起動

**コミット:** `d8c8f77 Replace Importmap + Hotwire with Inertia.js + React + Vite + Tailwind`

**変更ファイル:**

- `Gemfile`, `Gemfile.lock`
- `Dockerfile`, `compose.yml`, `Procfile.dev`
- `vite.config.ts`, `config/vite.json`
- `config/initializers/inertia_rails.rb`
- `config/routes.rb`
- `app/views/layouts/application.html.erb`
- `app/javascript/entrypoints/inertia.tsx`
- `app/javascript/entrypoints/application.css`
- `package.json`, `package-lock.json`
- `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`
- `bin/dev`, `bin/vite`

---

### Step 2: データベース設計・マイグレーション [完了 ✅]

**目的:** Users / Posts / Reactions テーブルを作成

**コミット:** `ba5d146 Add Users, Posts, Reactions tables (Step 2)`

#### Users テーブル

```ruby
create_table :users do |t|
  t.string :firebase_uid, null: false
  t.string :display_name
  t.string :avatar_url
  t.timestamps
end
add_index :users, :firebase_uid, unique: true
```

#### Posts テーブル

```ruby
create_table :posts do |t|
  t.references :user, null: false, foreign_key: true
  t.string :body, null: false, limit: 20
  t.integer :reactions_count, default: 0, null: false
  t.timestamps
end
add_index :posts, :created_at
```

- 写真は Active Storage（`has_one_attached :photo`）で管理
- `reactions_count` は counter_cache 用

#### Reactions テーブル

```ruby
create_table :reactions do |t|
  t.references :user, null: false, foreign_key: true
  t.references :post, null: false, foreign_key: true
  t.timestamps
end
add_index :reactions, [:user_id, :post_id], unique: true
```

**対象ファイル:**

- `db/migrate/20260214002818_create_users.rb`
- `db/migrate/20260214002820_create_posts.rb`
- `db/migrate/20260214002823_create_reactions.rb`
- `db/migrate/20260214002948_create_active_storage_tables.active_storage.rb`

---

### Step 3: モデル層 [完了 ✅]

**目的:** バリデーション、アソシエーション、スコープを定義

**コミット:** `c1367f1 Add User, Post, Reaction models with Active Storage (Step 3)`

#### User モデル (`app/models/user.rb`)

- `validates :firebase_uid, presence: true, uniqueness: true`
- `has_many :posts, dependent: :destroy`
- `has_many :reactions, dependent: :destroy`
- `.find_or_create_from_firebase(payload)` クラスメソッド

#### Post モデル (`app/models/post.rb`)

- `belongs_to :user`
- `has_one_attached :photo`
- `has_many :reactions, dependent: :destroy`
- `validates :body, presence: true, length: { maximum: 20 }`
- カスタムバリデーション: 改行不可、絵文字不可、ハッシュタグ不可
- `scope :tonight` — 18:00〜翌3:00 の投稿をフィルタ
- `scope :feed` — tonight + 新着順 + limit(10)

#### Reaction モデル (`app/models/reaction.rb`)

- `belongs_to :user`
- `belongs_to :post, counter_cache: true`
- `validates :user_id, uniqueness: { scope: :post_id }`

**対象ファイル:**

- `app/models/user.rb`（新規）
- `app/models/post.rb`（新規）
- `app/models/reaction.rb`（新規）

---

### Step 4: Firebase認証 [完了 ✅]

**目的:** Firebase IDトークンをRails側で検証し、セッションベースの認証を実現

**コミット:** `98320a9 Add Firebase authentication with session-based login (Step 4)`

#### 認証フロー

```
React (Firebase SDK)        Rails
─────────────────          ──────
1. Firebase Sign In
2. getIdToken()
3. POST /sessions ────────→ 4. JWT トークン検証
                            5. User.find_or_create_from_firebase
                            6. session[:user_id] = user.id
                   ←──────  7. Inertia redirect to /feed
```

#### FirebaseTokenVerifier (`app/services/firebase_token_verifier.rb`)

- `jwt` gem でRS256署名検証
- Google公開鍵を `Rails.cache.fetch` で1時間キャッシュ（Redis不要）
- claims検証: aud, iss, exp, iat

#### Authenticatable concern (`app/controllers/concerns/authenticatable.rb`)

- `before_action :require_login`
- `current_user` ヘルパー（session[:user_id] → User取得）
- 未認証時は /login にリダイレクト

#### SessionsController (`app/controllers/sessions_controller.rb`)

- `new`: ログインページ表示
- `create`: Firebase トークン検証 → セッション作成 → /feed リダイレクト
- `destroy`: セッションクリア → /login リダイレクト

**対象ファイル:**

- `app/services/firebase_token_verifier.rb`（新規）
- `app/controllers/concerns/authenticatable.rb`（新規）
- `app/controllers/sessions_controller.rb`（新規）
- `app/controllers/application_controller.rb`（更新）

---

### Step 5: コントローラ層（Inertia） [完了 ✅]

**目的:** Inertia対応のコントローラとルーティングを構築

**コミット:** `df76680 Add Feeds, Posts, Reactions controllers with Inertia shared data (Step 5)`

#### ルーティング (`config/routes.rb`)

```ruby
Rails.application.routes.draw do
  get  "login",    to: "sessions#new"
  post "sessions", to: "sessions#create"
  delete "session", to: "sessions#destroy"

  resource :feed, only: [:show]
  resources :posts, only: [:create]
  resources :reactions, only: [:create, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
  root "feeds#show"
end
```

#### FeedsController (`app/controllers/feeds_controller.rb`)

- `show`: `Post.feed` で最大10件取得、Inertia "Feed" ページを描画

#### PostsController (`app/controllers/posts_controller.rb`)

- `create`: 投稿作成、バリデーションエラー時はフラッシュで返却

#### ReactionsController (`app/controllers/reactions_controller.rb`)

- `create`: 「渋い」リアクション追加（find_or_create_by）
- `destroy`: リアクション解除

#### Inertia共有データ (`ApplicationController`)

```ruby
inertia_share do
  {
    current_user: current_user&.as_json(only: [:id, :display_name, :avatar_url]),
    flash: { notice: flash[:notice], alert: flash[:alert] }
  }
end
```

**対象ファイル:**

- `config/routes.rb`（更新）
- `app/controllers/feeds_controller.rb`（新規）
- `app/controllers/posts_controller.rb`（新規）
- `app/controllers/reactions_controller.rb`（新規）
- `app/controllers/application_controller.rb`（更新）

---

### Step 6: React フロントエンド [完了 ✅]

**目的:** ログイン・フィード・投稿・リアクションのUIを構築

**コミット:** `6b2a6f8 Add React frontend pages and Tailwind dark theme (Step 6 & 7)`

#### ディレクトリ構造

```
app/javascript/
  entrypoints/
    inertia.tsx          # エントリポイント（完了）
    application.css      # Tailwind CSS（完了）
  pages/
    Login.tsx            # ログインページ
    Feed.tsx             # フィード（メインページ）
  components/
    Layout.tsx           # 共通レイアウト（ダークテーマ）
    PostCard.tsx         # 投稿カード
    PostForm.tsx         # 投稿フォーム
    ReactionButton.tsx   # 「渋い」ボタン
    FlashMessage.tsx     # フラッシュメッセージ
  lib/
    firebase.ts          # Firebase初期化・Auth設定
```

#### Login.tsx

- Firebase Auth SDK でサインイン（Google / メールアドレス）
- サインイン成功 → `getIdToken()` → `Inertia.post('/sessions', { token })`

#### Feed.tsx

- 「今夜の至福」ヘッダー
- 投稿カード一覧（最大10件）
- 投稿ボタン
- 無限スクロールなし・フォロワー数なし・人気順なし

#### PostCard.tsx（仕様書 Section 6.3 準拠）

- ユーザー名（小さく）
- 写真（あれば）
- 一行テキスト
- 「渋い」ボタン + カウント（誰が押したかは非表示）
- 投稿時刻（相対表示）

#### PostForm.tsx

- テキスト入力（20文字制限、改行不可、絵文字・ハッシュタグ入力防止）
- 写真添付（1枚、任意）
- `Inertia.post('/posts', { body, photo })` で送信

#### ReactionButton.tsx

- 「渋い」トグルボタン
- 押しても演出なし（仕様書通り）
- カウントのみ表示

**対象ファイル:**

- `app/javascript/pages/Login.tsx`（新規）
- `app/javascript/pages/Feed.tsx`（新規）
- `app/javascript/components/Layout.tsx`（新規）
- `app/javascript/components/PostCard.tsx`（新規）
- `app/javascript/components/PostForm.tsx`（新規）
- `app/javascript/components/ReactionButton.tsx`（新規）
- `app/javascript/components/FlashMessage.tsx`（新規）
- `app/javascript/lib/firebase.ts`（新規）

---

### Step 7: UIデザイン（Tailwind） [完了 ✅]

**目的:** 仕様書準拠のダークUIテーマを構築

**コミット:** `6b2a6f8 Add React frontend pages and Tailwind dark theme (Step 6 & 7)`（Step 6と同時実施）

#### カラーパレット（`app/javascript/entrypoints/application.css` に定義）

```css
@theme {
  --color-bg: #0f0f0f;
  --color-text: #e5e5e5;
  --color-muted: #8a8a8a;
  --color-accent: #6b4e3d;
}
```

#### デザイン原則（仕様書 Section 6.2 準拠）

- ダークモード前提（bg: #0F0F0F）
- 余白を広く取る（padding/margin 大きめ）
- 文字を大きめに（base: 18px程度）
- アニメーション極小（transition 最小限）
- 音なし

**対象ファイル:**

- `app/javascript/entrypoints/application.css`（更新）

---

### Step 8: Firebase設定 [完了 ✅]

**目的:** Firebase プロジェクトとアプリの接続設定

#### Rails側 (`config/credentials.yml.enc`)

```yaml
firebase:
  project_id: "your-firebase-project-id"
```

#### React側 (`.env`)

```
VITE_FIREBASE_API_KEY=xxx
VITE_FIREBASE_AUTH_DOMAIN=xxx
VITE_FIREBASE_PROJECT_ID=xxx
```

#### 手動作業（Firebase Console）

- Firebase プロジェクト作成
- Authentication → Sign-in providers 有効化
- Web アプリ登録 → config取得

**対象ファイル:**

- `.env`（新規、.gitignore 済み）
- `config/credentials.yml.enc`（更新）

---

## 実装順序

| 順序 | ステップ                              | 状態        | コミット  |
| ---- | ------------------------------------- | ----------- | --------- |
| 1    | Step 1: フロントエンド基盤切り替え    | **完了** ✅ | `d8c8f77` |
| 2    | Step 2: DB マイグレーション           | **完了** ✅ | `ba5d146` |
| 3    | Step 3: モデル層                      | **完了** ✅ | `c1367f1` |
| 4    | Step 4: Firebase認証                  | **完了** ✅ | `98320a9` |
| 5    | Step 5: コントローラ層                | **完了** ✅ | `df76680` |
| 6    | Step 6 & 7: React フロントエンド + UI | **完了** ✅ | `6b2a6f8` |
| 7    | Step 8: Firebase設定                  | **完了** ✅ | 設定済み  |

---

## 検証方法

1. **起動確認:** `docker compose up` → `http://localhost:3000/up` で 200 OK
2. **認証テスト:** Firebase でログイン → セッション作成 → フィードへリダイレクト
3. **投稿テスト:** テキスト入力（20文字制限）→ 投稿 → フィードに表示
4. **写真テスト:** 写真添付投稿 → カードに画像表示
5. **リアクションテスト:** 「渋い」押下 → カウント増加、再押下で解除
6. **フィード制限テスト:** 11件以上投稿 → 最大10件のみ表示
7. **バリデーションテスト:** 21文字入力、絵文字入力 → エラー
8. **モデルテスト:** `bin/rails test` で User/Post/Reaction のバリデーション・スコープ確認

---

## 開発環境メモ

- Docker Compose で起動: `docker compose up`
- Rails はポート 3100（foreman offset）→ ホスト 3000 にマッピング
- Vite devサーバーはポート 3036
- `bin/dev` が foreman 経由で Vite + Rails を並列起動
- bundle/npm install はコンテナ起動時に自動実行
