#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v starship)" ]; then
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_SOURCE/starship/config.toml" "$HOME/.config/starship.toml"

    if [[ $(cat "$HOME/.config/starship.toml") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} starship config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading starship config"
    fi
else
    echo -e "🟨 ${YELLOW}starship not found, skipping${NC}"
fi
