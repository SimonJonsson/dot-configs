function wt --description 'Dispatch a palmtree worktree: symlink gitignored files, cd in, start claude in ultracode'
    if test (count $argv) -eq 0
        echo "usage: wt <worktree-path> [claude args...]" >&2
        return 1
    end

    set -l dir $argv[1]
    if not test -d $dir
        echo "wt: no such directory: $dir" >&2
        return 1
    end

    # Also runs `just py::sync`, which repoints the shared .venv's editable installs at
    # this worktree — without it, imports resolve against whichever worktree synced last.
    ~/.claude/scripts/setup-worktree.sh $dir
    or return 1

    cd $dir
    or return 1

    uc $argv[2..]
end
