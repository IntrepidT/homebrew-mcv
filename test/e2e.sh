#!/bin/sh
# E2E: build mcv from this working tree, install it via a throwaway local tap, and use it the way
# a teammate would (fresh $HOME, nested in their tmux). Exits non-zero on any failed check.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
H=/tmp/mcv-fakehome
B=/tmp/mcv-build
KEG=/opt/homebrew/opt/mcv/share/mcv
export HOMEBREW_NO_AUTO_UPDATE=1

failed=0
pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; failed=1; }
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

reset() {
  tmux -L mcv kill-server 2>/dev/null || true
  tmux -L mcvharness kill-server 2>/dev/null || true
  if [ -d "$H" ]; then chmod -R u+w "$H"; rm -rf "$H"; fi
}
reset

# Package the tree as a tarball in place of the git tag; brew infers the version from the filename.
VERSION=$(sed -n 's|^ *tag: *"v\(.*\)",*$|\1|p' "$REPO/Formula/mcv.rb")
rm -rf "$B" && mkdir -p "$B"
rsync -a --exclude .git "$REPO/" "$B/homebrew-mcv-$VERSION/"
tar -czf "$B/mcv-$VERSION.tar.gz" -C "$B" "homebrew-mcv-$VERSION"
SHA=$(shasum -a 256 "$B/mcv-$VERSION.tar.gz" | cut -d' ' -f1)
brew tap-new mcvtest/mcv --no-git >/dev/null 2>&1 || true
TAP=$(brew --repository mcvtest/mcv)
awk -v url="file://$B/mcv-$VERSION.tar.gz" -v sha="$SHA" '
  /^  url / { print "  url \"" url "\""; print "  sha256 \"" sha "\""; next }
  /^ +(tag|revision):/ || /^  head / { next }
  { print }' "$REPO/Formula/mcv.rb" >"$TAP/Formula/mcv.rb"

check "brew install" "brew reinstall mcvtest/mcv/mcv >$B/install.log 2>&1"
check "brew test" "brew test mcvtest/mcv/mcv >$B/test.log 2>&1"
check "brew style" "brew style mcvtest/mcv/mcv >$B/style.log 2>&1"
check "brew audit --strict" "brew audit --strict mcvtest/mcv/mcv >$B/audit.log 2>&1"

# A hostile host .zshrc: hard-sets HISTFILE, like many real ones do.
mkdir -p "$H"
printf 'export HOST_RC_LOADED=yes\nHISTFILE=~/.zsh_history\nsetopt INC_APPEND_HISTORY\n' >"$H/.zshrc"
cd /tmp
tmux -L mcvharness new-session -d -x 220 -y 50 "env HOME=$H TERM=xterm-256color mcv; sleep 900"
for _ in $(seq 600); do tmux -L mcv has-session 2>/dev/null && break; sleep 0.5; done
check "mcv session starts nested in host tmux" "tmux -L mcv has-session -t mcv 2>/dev/null"

drift=""
for d in "$H"/.local/share/mcv/lazy/*/; do
  n=$(basename "$d")
  want=$(python3 -c "import json;print(json.load(open('$REPO/config/nvim/lazy-lock.json')).get('$n',{}).get('commit',''))")
  have=$(git -C "$d" rev-parse HEAD)
  if [ -n "$want" ] && [ "$want" != "$have" ]; then drift="$drift $n"; fi
done
check "every plugin on its lazy-lock.json commit${drift:+ (drift:$drift)}" "[ -z '$drift' ]"
check "keg lockfile unchanged" "cmp -s '$REPO/config/nvim/lazy-lock.json' '$KEG/nvim/lazy-lock.json'"
check "resurrect bound to prefix C-s" "tmux -L mcv list-keys -T prefix C-s >/dev/null 2>&1"

sleep 2
# shellcheck disable=SC2016 # expands in the pane's shell, not here
tmux -L mcv send-keys -t mcv 'echo "rc=$HOST_RC_LOADED hist=$HISTFILE"' Enter
sleep 1
shell=$(tmux -L mcv capture-pane -p -t mcv | grep '^rc=' || true)
check "pane shell loads host .zshrc" "echo '$shell' | grep -q 'rc=yes'"
check "pane shell history goes to mcv state" "echo '$shell' | grep -q 'hist=$H/.local/state/mcv/'"

tmux -L mcv send-keys -t mcv 'nvim ~/.config/mcv/init.lua' Enter
for _ in $(seq 60); do tmux -L mcv capture-pane -p -t mcv | grep -q 'config.lazy' && break; sleep 0.5; done
for _ in $(seq 240); do [ -d "$H/.local/share/mcv/mason/packages/delve" ] && break; sleep 1; done
sleep 5
check "nvim opens with no errors on screen" "! tmux -L mcv capture-pane -p -t mcv | grep -qE 'E[0-9]+:|rror'"
check "Mason installed tools" "[ -d '$H/.local/share/mcv/mason/packages/delve' ]"
check "host ~/.zsh_history untouched" "[ ! -e '$H/.zsh_history' ]"
check "no Go/npm/pip caches in host dirs" "[ ! -e '$H/go' ] && [ ! -e '$H/.npm' ] && [ ! -e '$H/Library/Caches' ]"

# Clean while nvim and Mason are still running, as a real user would.
HOME=$H mcv clean >/dev/null
check "clean removes all mcv state" "[ ! -e '$H/.config/mcv' ] && [ ! -e '$H/.local/share/mcv' ] && [ ! -e '$H/.local/state/mcv' ] && [ ! -e '$H/.cache/mcv' ]"
check "clean stops the mcv tmux server" "! tmux -L mcv has-session 2>/dev/null"
leftover=$(cd "$H" && find . -type f -not -name .zshrc -not -path './.cache/tree-sitter/lock' \
  -not -path './Library/Application Support/go/telemetry/*' | tr '\n' ' ')
check "only known leftovers remain${leftover:+ (found: $leftover)}" "[ -z '$leftover' ]"

reset
brew uninstall mcvtest/mcv/mcv >/dev/null 2>&1 || true
brew untap mcvtest/mcv >/dev/null 2>&1 || true
if [ "$failed" = 0 ]; then rm -rf "$B"; echo "all checks passed"; else echo "logs in $B"; fi
exit "$failed"
