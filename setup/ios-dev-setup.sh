#!/bin/bash
# One-time setup for agent-driven iOS app development (Claude Code + simulator self-verification).
# Re-runnable: skips anything already installed. Run it in Terminal:  bash ~/ios-dev-setup.sh
set -e

bold() { printf "\n\033[1m%s\033[0m\n" "$1"; }

# ---------- 1. Xcode (must come from the App Store — can't be scripted) ----------
if [ ! -d /Applications/Xcode.app ]; then
  bold "STEP 1 of 2: Install Xcode first (the only manual step)."
  echo "Opening the App Store page now. Click 'Get' / 'Install' (~12 GB, takes a while)."
  echo "When it finishes, run this script again:  bash ~/ios-dev-setup.sh"
  open "macappstore://apps.apple.com/app/xcode/id497799835"
  exit 0
fi

bold "Xcode found. Pointing the command-line tools at it (you'll be asked for your Mac password)..."
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -runFirstLaunch || true

bold "Downloading the iOS simulator runtime (skipped if already present)..."
xcrun simctl list runtimes | grep -q iOS || xcodebuild -downloadPlatform iOS

# ---------- 2. Homebrew ----------
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  bold "Installing Homebrew (you may be asked for your Mac password again)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Make brew available in this shell and future ones
eval "$(/opt/homebrew/bin/brew shellenv)"
grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# ---------- 3. The verification toolchain (what the author's agent used) ----------
bold "Installing ffmpeg (frame recording), idb (simulator control), pipx, Pillow..."
brew install ffmpeg pipx python@3.11 || true
brew tap facebook/fb || true
brew trust facebook/fb 2>/dev/null || true   # Homebrew 6+ requires trusting third-party taps
brew install idb-companion || true
pipx ensurepath || true
# fb-idb breaks on Python 3.12+ (removed asyncio API) — pin to 3.11
pipx install --python "$(brew --prefix python@3.11)/bin/python3.11" fb-idb 2>/dev/null || true
pipx runpip fb-idb install Pillow 2>/dev/null || true
python3 -m pip install --user Pillow 2>/dev/null || true

# ---------- 4. Agent API keys file (optional, for image-gen / in-app agents) ----------
if [ ! -f ~/.agent-env ]; then
  bold "Creating ~/.agent-env — paste your API keys in later (optional)."
  cat > ~/.agent-env <<'EOF'
# Agent-scoped API keys, sourced by your shell so coding agents never have to ask.
# Fill in only what you need. Get keys from each provider's console.
# export ANTHROPIC_API_KEY=""   # for in-app AI agents (console.anthropic.com)
# export GEMINI_API_KEY=""      # for Nano Banana / Gemini image generation (aistudio.google.com)
# export OPENAI_API_KEY=""      # optional (platform.openai.com)
EOF
  grep -q '.agent-env' ~/.zshrc 2>/dev/null || echo '[ -f ~/.agent-env ] && source ~/.agent-env' >> ~/.zshrc
fi

# ---------- 5. Verify everything ----------
bold "Verifying the toolchain..."
xcodebuild -version | head -1
xcrun simctl list devices available | grep -m1 iPhone || echo "NOTE: no iPhone simulators yet — open Xcode once, it will create them."
ffmpeg -version | head -1
command -v idb_companion >/dev/null && echo "idb_companion: OK" || echo "idb_companion: MISSING"
command -v idb >/dev/null && echo "idb client: OK" || echo "idb client: restart Terminal, then check 'idb --help'"

bold "DONE. Open Claude Code in a NEW empty folder and run:  /ios-app-builder <your app idea>"
