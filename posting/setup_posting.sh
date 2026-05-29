#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v posting)" ]; then
    mkdir -p "$HOME/.config/posting"
    ln -sf "$DOTFILES_SOURCE/posting/config.yaml" "$HOME/.config/posting/config.yaml"

    if [[ $(cat "$HOME/.config/posting/config.yaml") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} posting config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading posting config"
    fi
else
    echo -e "🟨 ${YELLOW}posting not found, skipping${NC}"
fi
