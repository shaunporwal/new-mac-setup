
#!/usr/bin/env bash
set -euo pipefail

### ---------- Xcode Command-Line Tools ----------
xcode-select --install   # follow the GUI prompt  :contentReference[oaicite:3]{index=3}

### ---------- Homebrew ----------
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
brew update && brew upgrade

### ---------- Core CLI packages ----------
brew install pixi uv python@3.12                                 # dev tooling

### ---------- GUI & desktop apps ----------
brew install --cask iterm2 github signal whatsapp cursor google-chrome
# BetterSnapTool (window manager) is MAS-only — install manually via the App Store.

### ---------- Dock layout ----------
brew install dockutil                                            # Dock helper  :contentReference[oaicite:4]{index=4}

# 1) Clean just the applications section, leaving Downloads & Trash
dockutil --remove all --section apps --no-restart

# 2) Rebuild the Dock, top-to-bottom
dockutil --add '/System/Library/CoreServices/Finder.app' --no-restart          # 1 Finder
dockutil --add '/System/Applications/Messages.app' --no-restart                # 2 Messages
dockutil --add '/System/Applications/Mail.app' --no-restart                    # 3 Mail
dockutil --add '/System/Applications/Notes.app' --no-restart                   # 4 Notes
dockutil --add '/System/Applications/App Store.app' --no-restart               # 5 App Store
dockutil --add '/Applications/Google Chrome.app' --no-restart                  # 6 Chrome
dockutil --add '/Applications/Signal.app' --no-restart                         # 7 Signal
dockutil --add '/Applications/WhatsApp.app' --no-restart                       # 8 WhatsApp
dockutil --add '/Applications/iTerm.app' --no-restart                          # 9 iTerm
dockutil --add '/Applications/Cursor.app' --no-restart                         # 10 Cursor IDE
dockutil --add '/Applications/GitHub Desktop.app' --no-restart                 # 11 GitHub Desktop

# 3) Style: left side & auto-hide
defaults write com.apple.dock orientation -string left         # left edge  :contentReference[oaicite:5]{index=5}
defaults write com.apple.dock autohide -bool true              # auto-hide  :contentReference[oaicite:6]{index=6}

killall Dock   # one restart after everything

### ---------- Chrome extensions (still need one mouse-click each) ----------
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/nngceckbapebfimnlniiiahkandclblb"  # Bitwarden
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom"  # uBlock Origin
open -a "Google Chrome" "https://chrome.google.com/webstore/detail/<CURSORFUL_ID>"                     # Cursorful (replace ID)

echo "✅  All set!  Review any GUI prompts (Xcode tools, MAS sign-in, Chrome extension pop-ups) and enjoy your tailored Dock."

