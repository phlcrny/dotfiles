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

    ln -sf "$DOTFILES_SOURCE/vscode/ansible.json" "$VSCODE_ROOT/User/snippets/ansible.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/ansible.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code Ansible snippets"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VS Code Ansible snippets"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/powershell.json" "$VSCODE_ROOT/User/snippets/powershell.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/powershell.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code Powershell snippets"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VS Code Powershell snippets"
    fi

    ln -sf "$DOTFILES_SOURCE/vscode/python.json" "$VSCODE_ROOT/User/snippets/python.json"
    if [[ $(cat "$VSCODE_ROOT/User/snippets/python.json") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} VS Code Python snippets"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading VS Code Python snippets"
    fi
fi
