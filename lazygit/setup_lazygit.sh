#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [[ "$OSTYPE" == darwin* ]]; then
    LAZYGIT_CONFIG_PATH="$HOME/Library/Application Support/lazygit/config.yml"
    LAZYGIT_CONFIG_DIR="$HOME/Library/Application Support/lazygit"
else
    LAZYGIT_CONFIG_PATH="$HOME/.config/lazygit/config.yml"
    LAZYGIT_CONFIG_DIR="$HOME/.config/lazygit/"
fi

if [ -x "$(command -v lazygit)" ]; then
    mkdir -p "$LAZYGIT_CONFIG_DIR"
    ln -sf "$DOTFILES_SOURCE/lazygit/config.yml" "$LAZYGIT_CONFIG_PATH"

    if [[ $(cat "$LAZYGIT_CONFIG_PATH") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} lazygit config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading lazygit config"
    fi
else
    echo -e "🟨 ${YELLOW}lazygit not found, skipping${NC}"
fi
