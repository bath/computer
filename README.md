# computer

My macOS development environment, in a repo. Everything needed to take a fresh
MacBook Pro to a working setup for TypeScript/Node, Python, and mobile (iOS +
Android) development.

## What's here

| File | Purpose |
| --- | --- |
| `Brewfile` | Every CLI tool, application, and font, installed via Homebrew |
| `setup.sh` | Idempotent provisioning script — runtimes, git config, shell, macOS defaults |
| `docker-compose.dev.yml` | Local dev services: Postgres, Redis, Mailpit, MinIO |
| `.gitignore` | Global-ish ignore rules, with an aggressive secrets section |

## Fresh machine

```sh
git clone https://github.com/bath/computer.git ~/computer
cd ~/computer
./setup.sh --dry-run   # see what it will do
./setup.sh             # do it
exec zsh
```

`setup.sh` is safe to re-run. Each step checks current state before acting, and
the block it appends to `~/.zshrc` is fenced with markers so a second run leaves
it alone.

## Dev services

```sh
docker compose -f docker-compose.dev.yml up -d      # start
docker compose -f docker-compose.dev.yml ps         # status
docker compose -f docker-compose.dev.yml logs -f    # tail
docker compose -f docker-compose.dev.yml down       # stop
docker compose -f docker-compose.dev.yml down -v    # stop and drop data
```

After `setup.sh`, the `dcdev` alias is shorthand for the above.

| Service | Address | Credentials |
| --- | --- | --- |
| Postgres | `localhost:5432` | `dev` / `dev`, database `dev` |
| Redis | `localhost:6379` | none |
| Mailpit SMTP | `localhost:1025` | none |
| Mailpit UI | http://localhost:8025 | none |
| MinIO API | `localhost:9000` | `minioadmin` / `minioadmin` |
| MinIO Console | http://localhost:9001 | `minioadmin` / `minioadmin` |

Every port binds to `127.0.0.1`, so nothing is reachable from the network. The
credentials are throwaway local defaults; override them with a `.env` file
(git-ignored) if you care.

## Runtimes

Node and Python are managed by [mise](https://mise.jdx.dev), pinned globally by
`setup.sh` and overridable per project:

```sh
mise use node@22        # in a project directory
mise use python@3.11
```

Python packages and virtualenvs go through [uv](https://docs.astral.sh/uv/);
Node packages through `pnpm`.

## Mobile

`setup.sh` handles the parts that can be scripted — `openjdk@17`, `gradle`,
`cocoapods`, `fastlane`, `watchman`, `ANDROID_HOME`, and `JAVA_HOME`. Two steps
need a GUI and are left to you:

- **Xcode** — installs from the Mac App Store via the Brewfile, then run
  `sudo xcodebuild -license accept` and open it once to install components.
- **Android Studio** — open it once so it can download the SDK and create an
  emulator image.

## Secrets

This repo is public. `.gitignore` blocks `.env*`, `*.pem`, `*.key`, `*_rsa`,
`*_ed25519`, keystores, provisioning profiles, and service-account JSON. Nothing
sensitive should ever land here — check `git status` before you commit.

## Conventions

- `main` is the default branch; changes land through pull requests.
- No force-pushes, no history rewrites.
