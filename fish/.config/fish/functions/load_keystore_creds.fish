function load_keystore_creds
    if test (count $argv) -ne 1
        echo "Usage: load_keystore_creds <PREFIX>"
        return 1
    end

    set -l prefix_upper (string upper $argv[1])
    set -l entry_name (string lower $argv[1])
    set -l db_path "/home/pndhd/Documents/Passwords/Keystore.kdbx"

    echo "Loading keystore credentials for $prefix_upper..."
    
    set -l entry_data (keepassxc-cli show -s "$db_path" "$entry_name")
    
    if test $status -ne 0
        echo "❌ Error: Failed to read entry '$entry_name' from database"
        return 1
    end

    set -l in_notes 0
    for line in $entry_data
        if string match -q "Notes: *" $line
            set in_notes 1
            set line (string replace "Notes: " "" $line)
        end
        
        if test $in_notes -eq 1
            if string match -q "RELEASE_KEY_ALIAS=*" $line
                set -l value (string replace "RELEASE_KEY_ALIAS=" "" $line)
                set -l var_name "$prefix_upper"_RELEASE_KEY_ALIAS
                set -gx $var_name $value
                echo "✓ $var_name"
            else if string match -q "RELEASE_KEY_PASSWORD=*" $line
                set -l value (string replace "RELEASE_KEY_PASSWORD=" "" $line)
                set -l var_name "$prefix_upper"_RELEASE_KEY_PASSWORD
                set -gx $var_name $value
                echo "✓ $var_name"
            else if string match -q "RELEASE_STORE_PASSWORD=*" $line
                set -l value (string replace "RELEASE_STORE_PASSWORD=" "" $line)
                set -l var_name "$prefix_upper"_RELEASE_STORE_PASSWORD
                set -gx $var_name $value
                echo "✓ $var_name"
            end
        end
    end

    echo "✓ Keystore credentials loaded successfully!"
end
