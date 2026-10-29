#!/usr/bin/env bash
#
# One-shot machine setup: packages, symlinks, plugins. Safe to re-run.
#
#   ./install.sh                 full setup
#   ./install.sh --dry-run       print every step, change nothing
#   ./install.sh --links-only    only (re)create the symlinks
#   ./install.sh --no-packages   skip package installation
#   ./install.sh --no-plugins    skip tmux/nvim/fish plugin downloads
#   ./install.sh --set-shell     also make fish the login shell
#
# On a brand new machine, with nothing checked out yet:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/SimonJonsson/dot-configs/main/install.sh)
#
# That clones the repo to ~/Repos/dot-configs (override with $DOTFILES_DIR)
# and re-runs itself from there.

set -uo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/SimonJonsson/dot-configs.git}"
REPO_DEST="${DOTFILES_DIR:-$HOME/Repos/dot-configs}"

DRY_RUN=false
DO_PACKAGES=true
DO_LINKS=true
DO_PLUGINS=true
SET_SHELL=false

# ---------------------------------------------------------------- output ----

if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
    C_BLUE=$'\e[34m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_RED=$'\e[31m'
else
    C_RESET=''; C_BOLD=''; C_DIM=''; C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''
fi

WARNINGS=()

step() { printf '\n%s==>%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
skip() { printf '    %s·%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
warn() { printf '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; WARNINGS+=("$*"); }
die()  { printf '\n%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# Run a command, or just show it when --dry-run is set.
run() {
    if $DRY_RUN; then
        printf '    %s$ %s%s\n' "$C_DIM" "$*" "$C_RESET"
        return 0
    fi
    "$@"
}

usage() { awk 'NR>2 && /^#/ { sub(/^# ?/, ""); print; next } NR>2 { exit }' "$0"; exit 0; }

# ------------------------------------------------------------ where am i ----

# When piped from curl there is no file next to us, so clone first, then re-exec.
self_dir() {
    local src=${BASH_SOURCE[0]}
    [[ -f $src ]] || return 1
    cd -- "$(dirname -- "$src")" 2>/dev/null && pwd
}

REPO_DIR="$(self_dir || true)"
if [[ -z ${REPO_DIR:-} || ! -f $REPO_DIR/tmux/.config/tmux/tmux.conf ]]; then
    command -v git >/dev/null || die "git is required to bootstrap; install it and re-run"
    if [[ -d $REPO_DEST/.git ]]; then
        printf '==> updating existing checkout at %s\n' "$REPO_DEST"
        git -C "$REPO_DEST" pull --ff-only || die "could not fast-forward $REPO_DEST"
    else
        printf '==> cloning %s -> %s\n' "$REPO_URL" "$REPO_DEST"
        mkdir -p "$(dirname "$REPO_DEST")"
        git clone "$REPO_URL" "$REPO_DEST" || die "clone failed"
    fi
    exec bash "$REPO_DEST/install.sh" "$@"
fi

# ------------------------------------------------------------------ args ----

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)  DRY_RUN=true ;;
        --links-only)  DO_PACKAGES=false; DO_PLUGINS=false ;;
        --no-packages) DO_PACKAGES=false ;;
        --no-links)    DO_LINKS=false ;;
        --no-plugins)  DO_PLUGINS=false ;;
        --set-shell)   SET_SHELL=true ;;
        -h|--help)     usage ;;
        *)             die "unknown option: $1 (try --help)" ;;
    esac
    shift
done

case "$(uname -s)" in
    Linux)  OS=linux ;;
    Darwin) OS=macos ;;
    *)      die "unsupported platform: $(uname -s)" ;;
esac

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# -------------------------------------------------------------- packages ----

# Everything the configs in this repo actually need at runtime.
PKGS_ARCH=(
    stow git curl tmux neovim fish
    ripgrep fd unzip wl-clipboard
    lazygit yazi python-pipx
    ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd
    herdr   # from the omarchy repo; fails harmlessly on plain Arch
)

PKGS_BREW=(
    stow git curl tmux neovim fish
    ripgrep fd
    lazygit yazi pipx
    coreutils herdr
)

CASKS_BREW=(
    ghostty
    alacritty
    font-caskaydia-mono-nerd-font
    font-jetbrains-mono-nerd-font
    nikitabobko/tap/aerospace
)

install_packages_linux() {
    command -v pacman >/dev/null || {
        warn "not an Arch-based system; install these yourself: ${PKGS_ARCH[*]}"
        return
    }

    # Omarchy wraps pacman and skips anything already present.
    if command -v omarchy >/dev/null; then
        info "using omarchy pkg add"
        run omarchy pkg add "${PKGS_ARCH[@]}" || warn "some packages failed to install"
    else
        run sudo pacman -S --needed --noconfirm "${PKGS_ARCH[@]}" \
            || warn "some packages failed to install"
    fi
    ok "packages up to date"
}

install_packages_macos() {
    if ! command -v git >/dev/null; then
        warn "command line tools missing - running xcode-select --install"
        run xcode-select --install
        die "finish the Xcode command line tools install, then re-run this script"
    fi

    if ! command -v brew >/dev/null; then
        info "installing Homebrew"
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
            || die "Homebrew install failed"
        # Make brew usable in this shell for the rest of the run.
        for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            [[ -x $p ]] && eval "$("$p" shellenv)"
        done
    fi

    run brew install "${PKGS_BREW[@]}" || warn "some formulas failed to install"
    run brew tap nikitabobko/tap || true
    run brew install --cask "${CASKS_BREW[@]}" || warn "some casks failed to install"
    ok "packages up to date"
}

# ----------------------------------------------------------------- links ----

# Stow packages to link on every machine.
#   herdr   - config.toml only; the rest of ~/.config/herdr is sockets and logs
STOW_COMMON=(tmux nvim pypoetry yazi herdr)

# Directories stow must never fold into a single link to the repo, because the
# program writes runtime state next to the tracked file. Created before linking
# so stow links the file inside instead of the directory.
#   aerospace - smart-gaps.sh writes the real aerospace.toml next to the tracked
#               aerospace.base.toml, so it must not land in the repo
STOW_KEEP_DIRS=(.config/herdr .config/aerospace)

# Linux-only.
#   hypr    - Omarchy 4 Lua config: keybindings, grouping, look and feel
# Deliberately excluded:
#   waybar  - replaced by the Quickshell Omarchy shell
#   alacritty - Omarchy's own alacritty.toml follows `omarchy theme set` and
#               carries the CSI-u bindings tmux needs; ours would clobber both
STOW_LINUX=(hypr)

STOW_MACOS=(ghostty alacritty wezterm aerospace)

# Move anything real that sits where a symlink needs to go into a timestamped
# backup, so a fresh machine links cleanly without stow bailing out.
back_up() {
    local dest=$1 rel=$2
    if $DRY_RUN; then
        printf '    %s$ mv %s %s%s\n' "$C_DIM" "$dest" "$BACKUP_DIR/$rel" "$C_RESET"
    else
        mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        mv "$dest" "$BACKUP_DIR/$rel" && warn "backed up $dest -> $BACKUP_DIR/$rel"
    fi
}

# True when $dest already resolves to our copy of $src, i.e. it is either the
# link stow made or reached through an already-linked parent directory.
already_ours() {
    [[ "$(readlink -f -- "$1" 2>/dev/null)" == "$(readlink -f -- "$2")" ]]
}

relocate_conflicts() {
    local pkg=$1 src rel dest

    # Directories first: a dir that is a symlink pointing anywhere but here
    # blocks stow before it ever looks at the files inside it.
    while IFS= read -r -d '' src; do
        rel=${src#"$REPO_DIR/$pkg/"}
        [[ $rel == "$src" ]] && continue          # the package root itself
        dest=$HOME/$rel
        [[ -L $dest ]] || continue                # a real dir is fine, stow unfolds it
        already_ours "$dest" "$src" && continue
        back_up "$dest" "$rel"
    done < <(find "$REPO_DIR/$pkg" -name .git -prune -o -type d -print0)

    while IFS= read -r -d '' src; do
        rel=${src#"$REPO_DIR/$pkg/"}
        dest=$HOME/$rel
        [[ -e $dest || -L $dest ]] || continue
        already_ours "$dest" "$src" && continue
        back_up "$dest" "$rel"
    done < <(find "$REPO_DIR/$pkg" -name .git -prune -o -type f -print0)
}

stow_pkg() {
    local pkg=$1
    [[ -d $REPO_DIR/$pkg ]] || { warn "no stow package named '$pkg'"; return; }
    relocate_conflicts "$pkg"
    if $DRY_RUN; then
        stow --simulate --verbose=1 -d "$REPO_DIR" -t "$HOME" "$pkg" 2>&1 \
            | sed "s/^/    $C_DIM  /;s/\$/$C_RESET/"
        return
    fi
    if stow -d "$REPO_DIR" -t "$HOME" "$pkg"; then
        ok "linked $pkg"
    else
        warn "stow failed for $pkg"
    fi
}

link_configs() {
    run mkdir -p "$HOME/.config"
    local d
    for d in "${STOW_KEEP_DIRS[@]}"; do
        run mkdir -p "$HOME/$d"
    done

    local packages=("${STOW_COMMON[@]}")
    if [[ $OS == linux ]]; then
        packages+=("${STOW_LINUX[@]}")
    else
        packages+=("${STOW_MACOS[@]}")
    fi

    # fish config is only useful where fish is actually installed.
    if command -v fish >/dev/null; then
        packages+=(fish)
    else
        skip "fish not installed, not linking its config"
    fi

    local pkg
    for pkg in "${packages[@]}"; do
        stow_pkg "$pkg"
    done

    # aerospace.toml is generated from aerospace.base.toml (see smart-gaps.sh).
    if [[ $OS == macos ]]; then
        run "$HOME/.config/aerospace/smart-gaps.sh" --no-reload \
            && ok "generated aerospace.toml" || warn "smart-gaps.sh failed"
    fi
}

# ------------------------------------------------------------ mac apps ----

# Small launcher apps in ~/Applications, so Spotlight finds them by name.
build_mac_apps() {
    local src name app
    for src in "$REPO_DIR"/apps/*.applescript; do
        name=$(basename "$src" .applescript)
        app="$HOME/Applications/$name.app"
        run mkdir -p "$HOME/Applications"
        run rm -rf "$app"
        run osacompile -o "$app" "$src" || { warn "failed to build $name.app"; continue; }
        # Borrow Ghostty's icon so the launcher is recognisable in Spotlight.
        [[ -f /Applications/Ghostty.app/Contents/Resources/Ghostty.icns ]] \
            && run cp /Applications/Ghostty.app/Contents/Resources/Ghostty.icns \
                "$app/Contents/Resources/applet.icns"
        run touch "$app"
        ok "built $app"
    done
}

# --------------------------------------------------------------- plugins ----

install_tpm() {
    local dir="$HOME/.config/tmux/plugins/tpm"
    if [[ -d $dir/.git ]]; then
        run git -C "$dir" pull --ff-only --quiet && ok "tpm up to date"
    else
        run mkdir -p "$(dirname "$dir")"
        run git clone --depth 1 https://github.com/tmux-plugins/tpm "$dir" \
            && ok "tpm installed" || warn "tpm clone failed"
    fi
}

install_tmux_plugins() {
    local script="$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh"
    if [[ ! -x $script ]] && ! $DRY_RUN; then
        warn "tpm missing, skipping tmux plugins"
        return
    fi

    # tpm reads TMUX_PLUGIN_MANAGER_PATH from a running server, so source the
    # config explicitly - a server left over from before the symlinks were made
    # still has the old value and the install would fail.
    local started=false
    tmux ls >/dev/null 2>&1 || started=true

    run tmux start-server
    run tmux source-file "$HOME/.config/tmux/tmux.conf"
    run "$script" && ok "tmux plugins installed" || warn "tmux plugin install failed"
    $started && run tmux kill-server

    return 0
}

install_nvim_plugins() {
    command -v nvim >/dev/null || { skip "nvim not installed"; return; }
    info "syncing lazy.nvim plugins from lazy-lock.json (this can take a minute)"
    run nvim --headless "+Lazy! restore" +qa </dev/null \
        && ok "nvim plugins restored" || warn "nvim plugin restore failed"
}

install_poetry() {
    command -v pipx >/dev/null || { skip "pipx not installed"; return; }
    if command -v poetry >/dev/null; then
        skip "poetry already installed"
        return
    fi
    run pipx install poetry && ok "poetry installed" || warn "poetry install failed"
    run pipx ensurepath >/dev/null 2>&1
}

install_fisher() {
    command -v fish >/dev/null || { skip "fish not installed"; return; }
    if fish -c 'type -q fisher' 2>/dev/null; then
        skip "fisher already available"
    else
        run fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' \
            && ok "fisher installed" || warn "fisher install failed"
    fi
    if [[ -f $HOME/.config/fish/fish_plugins ]]; then
        run fish -c 'fisher update' || warn "fisher update failed"
    fi
}

set_login_shell() {
    local fish_path
    fish_path="$(command -v fish)" || { warn "fish not installed, cannot set shell"; return; }
    if [[ ${SHELL:-} == "$fish_path" ]]; then
        skip "fish is already the login shell"
        return
    fi
    grep -qxF "$fish_path" /etc/shells 2>/dev/null \
        || run sudo sh -c "echo '$fish_path' >> /etc/shells"
    run chsh -s "$fish_path" && ok "login shell set to fish" || warn "chsh failed"
}

# ------------------------------------------------------------------ main ----

printf '%s%s dot-configs setup %s\n' "$C_BOLD" "$C_BLUE" "$C_RESET"
info "repo:     $REPO_DIR"
info "platform: $OS"
$DRY_RUN && info "mode:     dry run, nothing will be changed"

step "Installing packages"
if $DO_PACKAGES; then
    case $OS in
        linux) install_packages_linux ;;
        macos) install_packages_macos ;;
    esac
else
    skip "skipped"
fi

step "Linking configs with stow"
if $DO_LINKS; then
    link_configs
else
    skip "skipped"
fi

if [[ $OS == macos ]] && $DO_LINKS; then
    step "Launcher apps"
    build_mac_apps
fi

if $DO_PLUGINS; then
    step "tmux plugins"
    install_tpm
    install_tmux_plugins

    step "Neovim plugins"
    install_nvim_plugins

    step "Python tooling"
    install_poetry

    step "fish plugins"
    install_fisher
else
    step "Plugins"; skip "skipped"
fi

if $SET_SHELL; then
    step "Login shell"
    set_login_shell
fi

step "Done"
if [[ -d $BACKUP_DIR ]]; then
    info "files that were in the way are in $BACKUP_DIR"
fi
if ((${#WARNINGS[@]})); then
    printf '    %s%d warning(s):%s\n' "$C_YELLOW" "${#WARNINGS[@]}" "$C_RESET"
    printf '      - %s\n' "${WARNINGS[@]}"
fi
info "open a new shell, or run: tmux source-file ~/.config/tmux/tmux.conf"
