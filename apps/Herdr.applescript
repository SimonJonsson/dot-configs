-- Compiled into ~/Applications/Herdr.app by install.sh so Spotlight can launch
-- herdr in its own Ghostty instance, separate from the everyday tmux one.
do shell script "open -na /Applications/Ghostty.app --args " & ¬
	"'--command=/opt/homebrew/bin/fish -l -c herdr' " & ¬
	"--title=herdr " & ¬
	"--window-save-state=never " & ¬
	"--quit-after-last-window-closed=true"
