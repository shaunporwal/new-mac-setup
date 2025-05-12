#!/usr/bin/env bash
###############################################################################
# install.sh – Idempotent macOS bootstrap                                     #
###############################################################################

set -euo pipefail  # exit on error, unset var, or pipefail

# ───────── 0. Self-healing CRLF guard ─────────
# If the script still has Windows CRLF line-endings, convert itself to LF
# and restart in the same shell.
if grep -q $'\r' "$0"; then
  printf '🔄 Detected CRLF line endings — converting to LF and restarting…\n'
  /usr/bin/sed -i '' $'s/\r$//' "$0"
  exec "$0" "$@"            # re-launch the now-clean file
fi

# ───────── helper ─────────
heading() { printf "\n\033[1;34m%s\033[0m\n" "$*"; }

######################################################################
#  1. Xcode Command-Line Tools                                       #
######################################################################
heading "🔧 Xcode Command-Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing CLT…"
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
else
  echo "✔︎ CLT already installed"
fi

######################################################################
#  2. Homebrew                                                       #
######################################################################
heading "🍺 Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✔︎ Homebrew already installed"
fi

# Make brew available in this shell
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update && brew upgrade

######################################################################
#  3. Core CLI packages                                              #
######################################################################
heading "📦 Core CLI packages"
brew install pixi uv python@3.12

######################################################################
#  4. GUI & desktop apps                                             #
######################################################################
heading "🖥  Desktop apps (casks)"
casks=(
  iterm2
  slack
  github
  signal
  whatsapp
  cursor
  google-chrome
)

for raw in "${casks[@]}"; do
  # strip any stray carriage returns (paranoia, now that CRLF is gone)
  cask=${raw//$'\r'/}

  app_path="/Applications/$(tr '-' ' ' <<<"$cask" | sed -E 's/\b(.)/\u\1/g').app"
  if brew list --cask "$cask" &>/dev/null || [[ -e "$app_path" ]]; then
    echo "✔︎ $cask already present"
  else
    echo "Installing ${cask}…"
    brew install --cask "$cask" || echo "✔︎ ${cask} already present (pre-installed)"
  fi
done

######################################################################
#  5. Dock layout                                                    #
######################################################################
heading "🚢 Dock layout"
brew list dockutil &>/dev/null || brew install dockutil

dockutil --remove all --section apps --no-restart    # clean apps section

apps=(
  "/System/Library/CoreServices/Finder.app"
  "/System/Applications/Messages.app"
  "/System/Applications/Mail.app"
  "/System/Applications/Notes.app"
  "/System/Applications/App Store.app"
  "/Applications/Google Chrome.app"
  "/Applications/Signal.app"
  "/Applications/WhatsApp.app"
  "/Applications/Slack.app"
  "/Applications/iTerm.app"
  "/Applications/Cursor.app"
  "/Applications/GitHub Desktop.app"
)
for app in "${apps[@]}"; do dockutil --add "$app" --no-restart; done

defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide   -bool   true
killall Dock   # restart once

######################################################################
#  6. Chrome extensions (one click required)                         #
######################################################################
heading "🌐 Pre-open Chrome extensions"
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/nngceckbapebfimnlniiiahkandclblb"  # Bitwarden
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom"  # uBlock Origin
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/<CURSORFUL_ID>"                     # Cursorful (replace ID)

echo -e "\n✅  All set!  Review any GUI prompts and enjoy your tailored Dock."
