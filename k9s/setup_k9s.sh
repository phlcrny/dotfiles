#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [[ "$OSTYPE" == darwin* ]]; then
    k9s_CONFIG_PATH="$HOME/Library/Application Support/k9s/config.yaml"
    k9s_CONFIG_DIR="$HOME/Library/Application Support/k9s"
else
    k9s_CONFIG_PATH="$HOME/.config/k9s/config.yaml"
    k9s_CONFIG_DIR="$HOME/.config/k9s/"
fi

if [ -x "$(command -v k9s)" ]; then
    mkdir -p "$k9s_CONFIG_DIR"
    ln -sf "$DOTFILES_SOURCE/k9s/config.yaml" "$k9s_CONFIG_PATH"

    if [[ $(cat "$k9s_CONFIG_PATH") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} k9s config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading k9s config"
    fi
else
    echo -e "🟨 ${YELLOW}k9s not found, skipping${NC}"
fi
