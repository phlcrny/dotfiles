#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v lsd)" ]; then
    mkdir -p "$HOME/.config/lsd"
    ln -sf "$DOTFILES_SOURCE/lsd/config.yaml" "$HOME/.config/lsd/config.yaml"

    if [[ $(cat "$HOME/.config/lsd/config.yaml") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} lsd config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading lsd config"
    fi

    ln -sf "$DOTFILES_SOURCE/lsd/colors.yaml" "$HOME/.config/lsd/colors.yaml"

    if [[ $(cat "$HOME/.config/lsd/colors.yaml") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} lsd colors"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading lsd colors"
    fi
else
    echo -e "🟨 ${YELLOW}lsd not found, skipping${NC}"
fi
