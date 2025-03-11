xcode-select --install

# Install fonts
brew tap hombrew/cask-fonts
brew install font-jetbrains-mono-nerd-font

# Python stuff
brew install python@3.13 python@3.12

brew install pipx
pipx install poetry

# Fish
brew install fish
fish

# Install Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

brew install yazi
brew install neovim
brew install alacritty
brew install tmux
