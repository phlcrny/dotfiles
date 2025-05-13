#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODE_ROOT="$HOME/.config/Code"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_ROOT="$HOME/Library/Application Support/Code"
fi

if [ -x "$(command -v code)" ]; then
    mkdir -p "$VSCODE_ROOT/User" && mkdir -p "$VSCODE_ROOT/User/snippets/"
    ln -sf "$DOTFILES_SOURCE/vscode/settings.json" "$VSCODE_ROOT/User/settings.json"

    code --install-extension dracula-theme.theme-dracula 2>&1 1>/dev/null
    if code --list-extensions | grep -q 'dracula-theme.theme-dracula'; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code Dracula theme"
    else
        echo -e "❌ ${RED}Error${NC} installing VS Code Dracula theme"
    fi

    if [[ $(cat "$VSCODE_ROOT/User/settings.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code settings"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VS Code settings"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/keybindings.json" "$VSCODE_ROOT/User/keybindings.json"
    if [[ $(cat "$VSCODE_ROOT/User/keybindings.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code keybindings"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VS Code keybindings"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/powershell.json" "$VSCODE_ROOT/User/snippets/powershell.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/powershell.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Powershell snippets for VS Code"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Powershell snippets for VS Code"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/python.json" "$VSCODE_ROOT/User/snippets/python.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/python.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Python snippets for VS Code"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Python snippets for VS Code"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/snippets/shellscript.json" "$VSCODE_ROOT/User/snippets/shellscript.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/shellscript.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} shellscript snippets for VS Code"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading shellscript snippets for VS Code"
    fi
fi
