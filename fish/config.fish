if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Created by `pipx` on 2025-03-12 09:34:35
set PATH $PATH /Users/simonjonsson/.local/bin

alias prun='poetry run nvim'
alias vim='nvim'
alias cls='clear'
alias tmuxkill='tmux kill-server && tmux || tmux'
alias lg='lazygit'
alias dbx_stg='rm -f ~/.databrickscfg && cp ~/.databrickscfg_stg ~/.databrickscfg'
alias dbx_dev='rm -f ~/.databrickscfg && cp ~/.databrickscfg_dev ~/.databrickscfg'
alias dbx_prd='rm -f ~/.databrickscfg && cp ~/.databrickscfg_prd ~/.databrickscfg'

# Created by `pipx` on 2025-03-14 07:53:37
set PATH $PATH /Users/simon/.local/bin
