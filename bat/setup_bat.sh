#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v bat)" ]; then
    mkdir -p "$HOME/.config/bat/"
    ln -sf "$DOTFILES_SOURCE/bat/config" "$HOME/.config/bat/config"

    if [[ $(cat "$HOME/.config/bat/config") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} bat config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading bat config"
    fi
else
    echo -e "🟨 ${YELLOW}bat not found, skipping${NC}"
fi
