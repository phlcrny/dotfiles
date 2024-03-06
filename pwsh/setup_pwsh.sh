#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v pwsh)" ]; then
    mkdir -p "$HOME/.config/powershell"
    ln -sf "$DOTFILES_SOURCE/pwsh/profile.ps1" "$HOME/.config/powershell/profile.ps1"
    if [[ $(cat "$HOME/.config/powershell/profile.ps1") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} pwsh profile"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading pwsh profile"
    fi

    mkdir -p "$HOME/.local/share/powershell/PSReadLine/"
    touch "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
    ln -sf "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt" "$HOME/.ps_history.txt"

    if [[ $(stat "$HOME/.ps_history.txt") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} PSReadline history symlink"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading PSReadline history symlink"
    fi
else
    echo -e "🟨 ${YELLOW}pwsh not found, skipping${NC}"
fi
