return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
    },
    keys = {
        {"<C-h>", "<cmd><C-u>TmuxNavigateLeft<CR>"},
        {"<C-l>", "<cmd><C-u>TmuxNavigateRight<CR>"},
        {"<C-j>", "<cmd><C-u>TmuxNavigateDown<CR>"},
        {"<C-k>", "<cmd><C-u>TmuxNavigateUp<CR>"},
    }

}
