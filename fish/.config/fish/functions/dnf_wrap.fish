function dnf_wrap --description "Create wrapper for binary with persistent flags"
    set -l META_DIR "/usr/local/lib/dnf-wrap/meta"
    set -l ACTIONS_DIR "/etc/dnf/libdnf5-plugins/actions.d"

    # Help
    if test (count $argv) -lt 2
        echo "Usage: dnf_wrap <path-to-binary> <flags...>"
        echo "Example: dnf_wrap /usr/bin/brave-browser --disable-gpu"
        echo ""
        echo "Commands:"
        echo "  dnf_wrap <binary> <flags>  - Create wrapper"
        echo "  dnf_unwrap <binary>        - Remove wrapper"
        echo "  dnf_wrap_list              - List all wrappers"
        return 1
    end

    set -l BIN_PATH $argv[1]
    set -l FLAGS $argv[2..]

    # Validate absolute path
    if not string match -q '/*' $BIN_PATH
        echo "Error: Please use absolute path"
        return 1
    end

    set -l BIN_NAME (basename $BIN_PATH)
    set -l BIN_HASH (echo $BIN_PATH | md5sum | cut -c1-8)
    set -l WRAPPER_ID "$BIN_NAME-$BIN_HASH"
    set -l REAL_BIN "$BIN_PATH-real"
    set -l RESTORE_SCRIPT "/usr/local/lib/dnf-wrap/restore-$WRAPPER_ID.sh"
    set -l HOOK_FILE "$ACTIONS_DIR/$WRAPPER_ID.actions"

    # Check if binary exists
    if not test -f $BIN_PATH; and not test -f $REAL_BIN
        echo "Error: $BIN_PATH not found"
        return 1
    end

    # Rename original if not already wrapped
    if test -f $REAL_BIN
        echo "Wrapper already exists. Updating flags..."
    else
        echo "Renaming $BIN_PATH -> $REAL_BIN"
        sudo mv $BIN_PATH $REAL_BIN
    end

    # Create wrapper script
    echo "Creating wrapper $BIN_PATH"
    set -l FLAGS_STR (string join ' ' -- $FLAGS)
    printf '%s\n' \
        '#!/bin/bash' \
        "# dnf-wrap: $WRAPPER_ID" \
        "exec \"$REAL_BIN\" $FLAGS_STR \"\$@\"" \
        | sudo tee $BIN_PATH >/dev/null
    sudo chmod +x $BIN_PATH

    # Create directories
    sudo mkdir -p $META_DIR

    # Create restore script (must be bash for dnf plugin)
    echo "Creating restore script $RESTORE_SCRIPT"
    printf '%s\n' \
        '#!/bin/bash' \
        "BIN_PATH=\"$BIN_PATH\"" \
        "REAL_BIN=\"$REAL_BIN\"" \
        "WRAPPER_ID=\"$WRAPPER_ID\"" \
        "FLAGS=\"$FLAGS_STR\"" \
        '' \
        'if [[ -x "$BIN_PATH" ]] && ! grep -q "dnf-wrap: $WRAPPER_ID" "$BIN_PATH" 2>/dev/null; then' \
        '    mv "$BIN_PATH" "$REAL_BIN"' \
        '    cat > "$BIN_PATH" << WRAPPER' \
        '#!/bin/bash' \
        '# dnf-wrap: $WRAPPER_ID' \
        'exec "$REAL_BIN" $FLAGS "\$@"' \
        'WRAPPER' \
        '    chmod +x "$BIN_PATH"' \
        '    logger "dnf-wrap: restored wrapper for $BIN_PATH"' \
        'fi' \
        | sudo tee $RESTORE_SCRIPT >/dev/null
    sudo chmod +x $RESTORE_SCRIPT

    # Install dnf plugin if needed
    if not rpm -q libdnf5-plugin-actions &>/dev/null
        echo "Installing libdnf5-plugin-actions..."
        sudo dnf install -y libdnf5-plugin-actions
    end
    sudo mkdir -p $ACTIONS_DIR

    # Create dnf hook (dnf5 format)
    echo "Creating dnf hook $HOOK_FILE"
    echo "post_transaction:$BIN_NAME:::$RESTORE_SCRIPT" | sudo tee $HOOK_FILE >/dev/null

    # Save metadata
    printf '%s\n' $BIN_PATH "$FLAGS_STR" | sudo tee "$META_DIR/$WRAPPER_ID" >/dev/null

    echo ""
    echo "Done! Wrapper for $BIN_PATH created."
    echo "  Flags: $FLAGS_STR"
end
