# Brewfile — macOS dev environment
# Apply with: brew bundle --file=Brewfile
# Preview:    brew bundle check --file=Brewfile --verbose

tap "homebrew/bundle"

# ─── Core CLI ────────────────────────────────────────────────────────────────
brew "git"
brew "gh"
brew "coreutils"
brew "curl"
brew "wget"
brew "jq"
brew "yq"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "eza"
brew "tree"
brew "htop"
brew "watch"
brew "tmux"
brew "direnv"

# ─── Runtime management ──────────────────────────────────────────────────────
# mise handles Node and Python versions per-project via .tool-versions / mise.toml
brew "mise"
brew "uv"          # fast Python package/venv manager
brew "pnpm"        # preferred Node package manager

# ─── Databases / infra clients ───────────────────────────────────────────────
brew "postgresql@16", restart_service: false, link: false  # client tools (psql)
brew "redis", restart_service: false, link: false          # client tools (redis-cli)

# ─── Mobile ──────────────────────────────────────────────────────────────────
brew "cocoapods"           # iOS dependency manager
brew "fastlane"            # iOS + Android build/release automation
brew "watchman"            # React Native file watching
brew "openjdk@17"          # Android Gradle toolchain
brew "gradle"
brew "xcodes"              # manage multiple Xcode versions

# ─── Quality of life ─────────────────────────────────────────────────────────
brew "shellcheck"
brew "gnupg"
brew "mas"                 # Mac App Store CLI

# ─── Applications ────────────────────────────────────────────────────────────
cask "ghostty"
cask "visual-studio-code"
cask "docker"              # Docker Desktop — provides `docker compose`
cask "android-studio"
cask "google-chrome"
cask "raycast"
cask "rectangle"
cask "postico"             # Postgres GUI
cask "proxyman"            # HTTP debugging for mobile

# ─── Fonts ───────────────────────────────────────────────────────────────────
cask "font-jetbrains-mono-nerd-font"

# ─── Mac App Store ───────────────────────────────────────────────────────────
# Xcode is large (~10GB). Comment out if you prefer `xcodes install --latest`.
mas "Xcode", id: 497799835
