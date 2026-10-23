# mcv

My tmux + Neovim (LazyVim) setup as a Homebrew tap, for working on someone else's Mac.
It runs beside the host's own setup and never touches it.

## Use

```sh
brew install intrepidt/mcv/mcv
mcv
```

When you're done on that machine:

```sh
mcv clean && brew uninstall mcv && brew untap intrepidt/mcv && brew autoremove
```

| Command | What it does |
| --- | --- |
| `mcv` | Start or attach to the mcv tmux session |
| `mcv nvim [args]` | Run mcv's Neovim outside tmux |
| `mcv clean` | Stop mcv's tmux server and delete all mcv state from `$HOME` |

The first launch installs plugins pinned to `lazy-lock.json`, which takes about a minute.
Mason installs LSPs and formatters in the background on the first Neovim start.
Icons need a Nerd Font in the terminal: `brew install --cask font-jetbrains-mono-nerd-font`.

## Isolation

- Neovim runs with `NVIM_APPNAME=mcv`, so it uses `~/.config/mcv` (a symlink into the keg) and `~/.{local/share,local/state,cache}/mcv`.
- tmux runs its own server (`tmux -L mcv`), so the host's sessions and config are untouched.
  If the host is already in tmux, mcv nests inside it.
- Pane shells still load the host's own dotfiles, so their PATH and tools work.
  Shell history is redirected into mcv's state dir via a `ZDOTDIR` shim.
- Go, npm, pip, node-gyp and Python caches created by Mason and LSPs go into `~/.cache/mcv`.
- dbee and gitlab.nvim are skipped under mcv: they need my credentials and a large Go build.

`mcv clean` removes everything above.
Known leftovers, which mcv cannot redirect without overriding `$HOME`: Go's telemetry counters in `~/Library/Application Support/go` (a few KB) and an empty `~/.cache/tree-sitter/lock`.

## Layout

```
Formula/mcv.rb        the formula
bin/mcv               launcher
config/nvim/          Neovim config (LazyVim), lazy-lock.json pins plugin commits
config/tmux/tmux.conf tmux config; tmux-resurrect is vendored by the formula
```

## Release

The formula pins a git tag plus its commit, not an archive checksum, so a regenerated archive can never break installs.

1. Run `test/e2e.sh` and make sure every check passes.
2. Commit, then tag: `git tag v0.1.1`.
3. In `Formula/mcv.rb`, set `tag:` to `v0.1.1` and `revision:` to the output of `git rev-parse v0.1.1^{commit}`, then commit.
4. Push both: `git push origin main v0.1.1`.
5. On any machine: `brew update && brew upgrade mcv`.
   The next `mcv` launch re-pins plugins if `lazy-lock.json` changed.

To try `main` without releasing, run `brew install --HEAD intrepidt/mcv/mcv`.
