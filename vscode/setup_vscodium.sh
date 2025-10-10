#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODIUM_ROOT="$HOME/.config/VSCodium"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODIUM_ROOT="$HOME/Library/Application Support/VSCodium"
fi

if [ -x "$(command -v codium)" ]; then
    mkdir -p "$VSCODIUM_ROOT/User" && mkdir -p "$VSCODIUM_ROOT/User/snippets/"
    ln -sf "$DOTFILES_SOURCE/vscode/settings.json" "$VSCODIUM_ROOT/User/settings.json"

    codium --install-extension dracula-theme.theme-dracula 2>&1 1>/dev/null
    if codium --list-extensions | grep -q 'dracula-theme.theme-dracula'; then
        echo -e "✅ ${GREEN}Installed${NC} VSCodium Dracula theme"
    else
        echo -e "❌ ${RED}Error${NC} installing VSCodium Dracula theme"
    fi

    if [[ $(cat "$VSCODIUM_ROOT/User/settings.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VSCodium settings"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VSCodium settings"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/keybindings.json" "$VSCODIUM_ROOT/User/keybindings.json"
    if [[ $(cat "$VSCODIUM_ROOT/User/keybindings.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VSCodium keybindings"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VSCodium keybindings"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/powershell.json" "$VSCODIUM_ROOT/User/snippets/powershell.json"
    if [[ $(cat "$VSCODIUM_ROOT/User/snippets/powershell.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Powershell snippets for VSCodium"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Powershell snippets for VSCodium"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/python.json" "$VSCODIUM_ROOT/User/snippets/python.json"
    if [[ $(cat "$VSCODIUM_ROOT/User/snippets/python.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Python snippets for VSCodium"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Python snippets for VSCodium"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/shellscript.json" "$VSCODIUM_ROOT/User/snippets/shellscript.json"
    if [[ $(cat "$VSCODIUM_ROOT/User/snippets/shellscript.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} shellscript snippets for VSCodium"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading shellscript snippets for VSCodium"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/yaml.json" "$VSCODIUM_ROOT/User/snippets/yaml.json"
    if [[ $(cat "$VSCODIUM_ROOT/User/snippets/yaml.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} YAML snippets for VSCodium"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading YAML snippets for VSCodium"
    fi
fi
