#!/usr/bin/env bash
#
# setup.sh — provision a fresh macOS machine for TS/Node, Python, and mobile work.
#
# Safe to run more than once; every step checks before it acts.
#
#   ./setup.sh            # full run
#   ./setup.sh --dry-run  # print what would happen, change nothing
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
SHELL_MARKER_BEGIN="# >>> computer/setup.sh >>>"
SHELL_MARKER_END="# <<< computer/setup.sh <<<"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      grep '^#' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' | head -12
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

# ─── Output helpers ──────────────────────────────────────────────────────────
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" = true ]; then
    printf '\033[2m  would run: %s\033[0m\n' "$*"
  else
    "$@"
  fi
}

# ─── Preflight ───────────────────────────────────────────────────────────────
[ "$(uname -s)" = "Darwin" ] || die "This script targets macOS only."

info "Machine: $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))"

# ─── Xcode Command Line Tools ────────────────────────────────────────────────
info "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "already installed at $(xcode-select -p)"
else
  warn "installing — accept the GUI prompt, then re-run this script"
  run xcode-select --install
  exit 0
fi

# ─── Homebrew ────────────────────────────────────────────────────────────────
info "Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "already installed ($(brew --version | head -1))"
else
  warn "installing Homebrew"
  run /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ─── Brewfile ────────────────────────────────────────────────────────────────
info "Homebrew packages"
if [ -f "$REPO_DIR/Brewfile" ]; then
  run brew bundle --file="$REPO_DIR/Brewfile"
  ok "Brewfile applied"
else
  warn "no Brewfile found at $REPO_DIR/Brewfile — skipping"
fi

# ─── Language runtimes ───────────────────────────────────────────────────────
info "Language runtimes (mise)"
if command -v mise >/dev/null 2>&1; then
  run mise use --global node@lts
  run mise use --global python@3.12
  ok "node@lts and python@3.12 pinned globally"
else
  warn "mise not on PATH — skipping runtime pinning"
fi

# ─── Git configuration ───────────────────────────────────────────────────────
info "Git configuration"
run git config --global init.defaultBranch main
run git config --global pull.rebase true
run git config --global fetch.prune true
run git config --global push.autoSetupRemote true
run git config --global rebase.autoStash true
run git config --global diff.colorMoved zebra
run git config --global core.excludesfile "$HOME/.gitignore_global"

if [ -z "$(git config --global user.name || true)" ]; then
  warn "git user.name is unset — set it with: git config --global user.name 'Your Name'"
else
  ok "git identity: $(git config --global user.name) <$(git config --global user.email)>"
fi

# ─── Shell environment ───────────────────────────────────────────────────────
info "Shell environment (~/.zshrc)"
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && grep -qF "$SHELL_MARKER_BEGIN" "$ZSHRC"; then
  ok "managed block already present — leaving it alone"
elif [ "$DRY_RUN" = true ]; then
  printf '\033[2m  would append managed block to %s\033[0m\n' "$ZSHRC"
else
  cat >>"$ZSHRC" <<'ZSHRC_BLOCK'

# >>> computer/setup.sh >>>
# Managed by https://github.com/bath/computer — edit above or below this block.

# Homebrew
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Runtime management
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

# Java (Android Gradle toolchain)
if [ -d /opt/homebrew/opt/openjdk@17 ]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# Aliases
alias ll='eza -lah --group-directories-first'
alias cat='bat --paging=never'
alias gs='git status --short --branch'
alias gd='git diff'
alias dcdev='docker compose -f "$HOME/computer/docker-compose.dev.yml"'

# History
export HISTSIZE=50000
export SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY
# <<< computer/setup.sh <<<
ZSHRC_BLOCK
  ok "managed block appended"
fi

# ─── macOS defaults ──────────────────────────────────────────────────────────
info "macOS defaults"
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder AppleShowAllFiles -bool true
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.dock autohide -bool true
run defaults write com.apple.screencapture location -string "$HOME/Desktop"
ok "defaults written (some need a logout to take effect)"

# ─── Done ────────────────────────────────────────────────────────────────────
echo
info "Setup complete."
cat <<'NEXT_STEPS'

Next steps:
  1. Restart your shell:      exec zsh
  2. Start dev services:      dcdev up -d
  3. Sign in to the tools:    gh auth login
  4. Accept the Xcode EULA:   sudo xcodebuild -license accept
  5. Android SDK: open Android Studio once to finish the SDK install.

NEXT_STEPS
