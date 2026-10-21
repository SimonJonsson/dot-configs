# dot-configs

Personal configs for Arch/[Omarchy](https://omarchy.org/) and macOS, linked into
place with GNU stow so edits land straight back in this repo.

## Setup

On a machine with nothing checked out yet:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/SimonJonsson/dot-configs/main/install.sh)
```

That clones the repo to `~/Repos/dot-configs` (override with `$DOTFILES_DIR`) and
re-runs itself from there. If the repo is already cloned:

```sh
./install.sh
```

The script installs packages, links the configs, and downloads the tmux, Neovim
and fish plugins. It is safe to re-run — that is also how you pull in a new
package or a new config directory later.

```
./install.sh --dry-run       print every step, change nothing
./install.sh --links-only    only (re)create the symlinks
./install.sh --no-packages   skip package installation
./install.sh --no-plugins    skip plugin downloads
./install.sh --set-shell     also make fish the login shell
```

Anything real sitting where a symlink needs to go is moved to
`~/.dotfiles-backup/<timestamp>/` rather than deleted, so a first run on a
machine that already has configs is not destructive. Files that stow does not
own are left alone.

## Layout

Each top-level directory is a stow package: its contents mirror `$HOME`.

| Package     | Links to              | Linked on      |
| ----------- | --------------------- | -------------- |
| `tmux`      | `~/.config/tmux`      | everywhere     |
| `nvim`      | `~/.config/nvim`      | everywhere     |
| `pypoetry`  | `~/.config/pypoetry`  | everywhere     |
| `yazi`      | `~/.config/yazi`      | everywhere     |
| `herdr`     | `~/.config/herdr/config.toml` | everywhere |
| `fish`      | `~/.config/fish`      | where fish is installed |
| `ghostty`   | `~/.config/ghostty`   | macOS only     |
| `alacritty` | `~/.config/alacritty` | macOS only     |
| `wezterm`   | `~/.config/wezterm`   | macOS only     |
| `aerospace` | `~/.config/aerospace` | macOS only     |
| `hypr`      | `~/.config/hypr`      | not linked — see below |
| `waybar`    | `~/.config/waybar`    | not linked — see below |

To add a package, create the directory and add its name to `STOW_COMMON`,
`STOW_LINUX` or `STOW_MACOS` in `install.sh`. If the program keeps runtime
state next to its config (herdr writes sockets, logs and `session.json` into
`~/.config/herdr`), also add the directory to `STOW_KEEP_DIRS` so stow links
the file rather than folding the whole directory into the repo.

## herdr

`herdr/.config/herdr/config.toml` mirrors the Omarchy tmux config: workspace,
tab and pane keys under a `ctrl+space` prefix, terminal palette, no gaps. Reload
a running server after editing it with `herdr server reload-config`.

On macOS, `install.sh` also builds a launcher app in `~/Applications` for each
script in `apps/`: type "herdr" or "tmux" into Spotlight and it opens a separate
Ghostty instance running that, while plain Ghostty keeps opening tmux.

## Agent skills and configs

Skills and settings for the coding-agent CLIs (Claude Code, Codex, OpenCode,
pi, ...) live in a separate repo,
[agent-configs](https://github.com/SimonJonsson/agent-configs), with its own
`install.sh` that links them into every provider on the machine. They are kept
apart from this repo because they are shared across tools rather than tied to
a desktop, and change on a different cadence.

## tmux on Omarchy

`tmux/.config/tmux/tmux.conf` is a thin loader:

- On Omarchy it sources the *live* `/usr/share/omarchy/config/tmux/tmux.conf`,
  so `omarchy update` keeps flowing through untouched.
- Everywhere else it falls back to `omarchy.conf`, a verbatim copy of that same
  file, so the look, feel and keybindings match on macOS.
- `personal.conf` is layered on top: tpm, `vim-tmux-navigator` (`Ctrl` + `hjkl`
  across tmux panes and nvim splits), and resurrect/continuum session
  persistence. It deliberately does not restyle the status bar — Omarchy's is
  palette-free so tmux follows `omarchy theme set`.

Re-sync the macOS fallback copy after an Omarchy update:

```sh
diff /usr/share/omarchy/config/tmux/tmux.conf ~/.config/tmux/omarchy.conf
```

Note that `vim-tmux-navigator` claims `C-k` at the root level, so readline's
kill-to-end-of-line no longer reaches the shell. `C-l` is still available as
`prefix + C-l`.

## Not linked on Linux

Three packages are checked in but deliberately left out of the Linux run:

- **`hypr`** — targets the pre-4.x Omarchy `.conf` layout and sources
  `~/.local/share/omarchy/`, a path that no longer exists. Omarchy 4 configures
  Hyprland in Lua. Worth salvaging from it: `GDK_SCALE=2` with `3440x1440@100`,
  `compose:caps`, `repeat_rate 40` / `repeat_delay 600`, `numlock_by_default`,
  touchpad `scroll_factor 0.4`.
- **`waybar`** — replaced by the Quickshell-based Omarchy shell
  (`~/.config/omarchy/shell.json`).
- **`alacritty`** — Omarchy ships its own, which follows `omarchy theme set` and
  carries the CSI-u keyboard bindings that Omarchy's tmux `M-S-Enter` split
  depends on. Ours has neither, and pins `/usr/bin/fish` as the shell.
