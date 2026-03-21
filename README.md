# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite
  - RSpec: `bin/rspec`（Docker: `docker compose run --rm web bin/rspec`）
  - テストデータ: [Factory Bot](https://github.com/thoughtbot/factory_bot)（`spec/factories/`）

- フロントエンド（`app/javascript`）
  - 規約: [docs/frontend-conventions.md](docs/frontend-conventions.md)
  - 型: `npm run check` / Lint: `npm run lint` / 整形: `npm run format` / `npm run format:check`

- ドキュメント（Cursor / Claude Code 共通）
  - 索引: [docs/README.md](docs/README.md)
  - Claude Code: ルートの [CLAUDE.md](CLAUDE.md)
  - Cursor: [.cursor/rules/reference-docs.mdc](.cursor/rules/reference-docs.mdc)（`docs/` 参照を常時指示）

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

（`-t` はレジストリとタグに合わせて置き換え。例: `docker.io/<user>/midlife-joy:dev`）

```
set -a && source .env && set +a
docker build --no-cache -f Dockerfile.prod --platform linux/amd64 \
  --secret id=vite_firebase_api_key,env=VITE_FIREBASE_API_KEY \
  --secret id=vite_firebase_auth_domain,env=VITE_FIREBASE_AUTH_DOMAIN \
  --secret id=vite_firebase_project_id,env=VITE_FIREBASE_PROJECT_ID \
  -t YOUR_REGISTRY/midlife-joy:TAG .
```

- ...
