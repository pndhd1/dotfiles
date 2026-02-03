function dnf_wrap_list --description "List all wrapped binaries"
    set -l META_DIR "/usr/local/lib/dnf-wrap/meta"

    if not test -d $META_DIR; or test (count $META_DIR/*) -eq 0
        echo "No wrapped applications."
        return 0
    end

    echo "Wrapped applications:"
    echo ""

    for meta_file in $META_DIR/*
        test -f $meta_file; or continue

        set -l bin_path (sed -n '1p' $meta_file)
        set -l flags (sed -n '2p' $meta_file)
        set -l real_bin "$bin_path-real"

        set -l status_str "broken"
        if test -f $real_bin
            set status_str "active"
        end

        echo "  $bin_path"
        echo "    Flags:  $flags"
        echo "    Status: $status_str"
        echo ""
    end
end
