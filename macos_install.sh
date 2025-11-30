# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Create symlinks
chmod +x ./symlinks.sh
./symlinks.sh

stow -t ~ nvim
stow -t ~ tmux
stow -t ~ alacritty
stow -t ~ aerospace
stow -t ~ pypoetry
stow -t ~ fish
stow -t ~ yazi

xcode-select --install

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install fonts
brew tap hombrew/cask-fonts
brew install font-jetbrains-mono-nerd-font

# Python stuff
brew install python@3.13 python@3.12 python@3.11

brew install pipx
pipx install poetry

# Fish
brew install fish

# Add fish to allowed shells
if ! grep -q "/opt/homebrew/bin/fish" /etc/shells; then
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi

# Set fish as default shell
chsh -s /opt/homebrew/bin/fish

# Set fish to allowed shell and default shell
sudo echo $(which fish) >>/etc/shells
chsh -s $(which fish)

brew install yazi
brew install lazygit
brew install neovim
brew install --cask alacritty
brew install tmux
brew install stow

# Install Tmux Plugin Manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Source tmux config and install plugins
tmux start-server
tmux new-session -d
~/.config/tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server

# Install Fisher
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish
