# Open a new Ghostty window attached to the persistent herdr session.
# `open -na` is required: the running Ghostty instance ignores --args.
function hd --description 'herdr in a fresh Ghostty window'
    open -na Ghostty --args --command=$HOME/.local/bin/herdr $argv
end
