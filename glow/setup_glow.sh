#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [[ "$OSTYPE" == darwin* ]]; then
    GLOW_CONFIG_PATH="$HOME/Library/Preferences/glow/glow.yml"
    GLOW_CONFIG_DIR="$HOME/Library/Preferences/glow/"
else
    GLOW_CONFIG_PATH="$HOME/.config/glow/glow.yml"
    GLOW_CONFIG_DIR="$HOME/.config/glow/"
fi

if [ -x "$(command -v glow)" ]; then
    mkdir -p "$GLOW_CONFIG_DIR"
    ln -sf "$DOTFILES_SOURCE/glow/glow.yml" "$GLOW_CONFIG_PATH"

    if [[ $(cat "$GLOW_CONFIG_PATH") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} glow config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading glow config"
    fi
else
    echo -e "🟨 ${YELLOW}glow not found, skipping${NC}"
fi
