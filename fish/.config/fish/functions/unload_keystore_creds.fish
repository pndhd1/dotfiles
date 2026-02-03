function unload_keystore_creds
    if test (count $argv) -ne 1
        echo "Usage: unload_keystore_creds <PREFIX>"
        return 1
    end

    set -l prefix_upper (string upper $argv[1])

    echo "Unloading keystore credentials for $prefix_upper..."
    
    # Формируем имена переменных
    set -l var_alias "$prefix_upper"_RELEASE_KEY_ALIAS
    set -l var_key_pass "$prefix_upper"_RELEASE_KEY_PASSWORD
    set -l var_store_pass "$prefix_upper"_RELEASE_STORE_PASSWORD
    
    # Удаляем переменные окружения
    if set -q $var_key_pass
        set -e $var_key_pass
        echo "✓ Removed $var_key_pass"
    end
    
    if set -q $var_alias
        set -e $var_alias
        echo "✓ Removed $var_alias"
    end
    
    if set -q $var_store_pass
        set -e $var_store_pass
        echo "✓ Removed $var_store_pass"
    end

    echo "✓ Keystore credentials unloaded successfully!"
end
