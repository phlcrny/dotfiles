#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v dig)" ]; then
    ln -sf "$DOTFILES_SOURCE/dig/digrc" "$HOME/.digrc"

    if [[ $(cat "$HOME/.digrc") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} dig config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading dig config"
    fi
else
    echo -e "🟨 ${YELLOW}dig not found, skipping${NC}"
fi
