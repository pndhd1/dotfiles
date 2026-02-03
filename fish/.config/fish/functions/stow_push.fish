function stow_push --description "Fetch, add and commit dotfiles changes"
    set -l src ~/dotfiles

    git -C $src fetch
    and git -C $src add -A

    set -l changes (git -C $src diff --cached --name-status)

    if test -z "$changes"
        echo "No changes to commit"
        return 0
    end

    set -l added
    set -l modified
    set -l deleted

    for line in $changes
        set -l st (string sub -l 1 $line)
        set -l file (string sub -s 3 $line)

        switch $st
            case A
                set -a added $file
            case M
                set -a modified $file
            case D
                set -a deleted $file
        end
    end

    set -l parts

    if test (count $added) -gt 0
        set -a parts "add: "(string join ", " $added)
    end

    if test (count $modified) -gt 0
        set -a parts "update: "(string join ", " $modified)
    end

    if test (count $deleted) -gt 0
        set -a parts "remove: "(string join ", " $deleted)
    end

    set -l msg (string join "; " $parts)

    echo "Commit: $msg"
    git -C $src commit -m "$msg"
    and git -C $src push
end
