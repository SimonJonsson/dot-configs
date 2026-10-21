-- Compiled into ~/Applications/Tmux.app by install.sh so Spotlight can launch
-- the everyday tmux session in its own Ghostty instance, next to Herdr.app.
do shell script "open -na /Applications/Ghostty.app --args " & ¬
	"'--command=/opt/homebrew/bin/fish -l -c \"tmux attach || tmux -2\"' " & ¬
	"--title=tmux " & ¬
	"--window-save-state=never " & ¬
	"--quit-after-last-window-closed=true"
