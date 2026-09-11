if status is-interactive
    # Omarchy's omarchy-fish package turns on vi mode system-wide in
    # /usr/share/fish/vendor_conf.d/init.fish. That drops the emacs-style
    # bindings (ctrl-f accepts the autosuggestion, ctrl-a/ctrl-e, ...) used on
    # the Mac. config.fish runs after vendor_conf.d, so restore them here.
    fish_default_key_bindings
end

# Created by `pipx` on 2025-03-12 09:34:35
set PATH $PATH /Users/simonjonsson/.local/bin

alias prun='poetry run nvim'

# Run nvim with palmtree's uv environment
function pn
    uv run --project /Users/simon/Repos/palmtree nvim $argv
end

# Run arbitrary commands with palmtree's uv environment
function puv
    uv run --project /Users/simon/Repos/palmtree $argv
end
alias vim='nvim'
alias cls='clear'
alias tmuxkill='tmux kill-server && tmux || tmux'
alias lg='lazygit'
alias dbx_stg='rm -f ~/.databrickscfg && cp ~/.databrickscfg_stg ~/.databrickscfg'
alias dbx_dev='rm -f ~/.databrickscfg && cp ~/.databrickscfg_dev ~/.databrickscfg'
alias dbx_prd='rm -f ~/.databrickscfg && cp ~/.databrickscfg_prd ~/.databrickscfg'
#
# Ensure LLVM clangd takes precedence over Apple clangd
set -gx PATH /opt/homebrew/opt/llvm/bin $PATH

# Created by `pipx` on 2025-03-14 07:53:37
set PATH $PATH /Users/simon/.local/bin

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/simon/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/simon/Downloads/google-cloud-sdk/path.fish.inc'; end

# Created by `pipx` on 2026-02-24 16:52:06
set PATH $PATH /home/simon/.local/bin
