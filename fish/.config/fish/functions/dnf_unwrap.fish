function dnf_unwrap --description "Remove wrapper and restore original binary"
    if test (count $argv) -lt 1
        echo "Usage: dnf_unwrap <path-to-binary>"
        echo "Example: dnf_unwrap /usr/bin/brave-browser"
        return 1
    end

    set -l BIN_PATH $argv[1]

    # Validate absolute path
    if not string match -q '/*' $BIN_PATH
        echo "Error: Please use absolute path"
        return 1
    end

    set -l BIN_NAME (basename $BIN_PATH)
    set -l BIN_HASH (echo $BIN_PATH | md5sum | cut -c1-8)
    set -l WRAPPER_ID "$BIN_NAME-$BIN_HASH"
    set -l REAL_BIN "$BIN_PATH-real"

    if not test -f $REAL_BIN
        echo "Error: No wrapper found for $BIN_PATH"
        return 1
    end

    echo "Restoring original $BIN_PATH"
    sudo rm -f $BIN_PATH
    sudo mv $REAL_BIN $BIN_PATH

    echo "Cleaning up..."
    sudo rm -f "/usr/local/lib/dnf-wrap/restore-$WRAPPER_ID.sh"
    sudo rm -f "/etc/dnf/libdnf5-plugins/actions.d/$WRAPPER_ID.actions"
    # Clean up old dnf4 hook if exists
    sudo rm -f "/etc/dnf/plugins/post-transaction-actions.d/$WRAPPER_ID.action"
    sudo rm -f "/usr/local/lib/dnf-wrap/meta/$WRAPPER_ID"

    echo "Done! Wrapper for $BIN_PATH removed."
end
