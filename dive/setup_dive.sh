#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v dive)" ]; then
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_SOURCE/dive/config.yml" "$HOME/.dive.yml"

    if [[ $(cat "$HOME/.dive.yml") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} dive config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading dive config"
    fi
else
    echo -e "🟨 ${YELLOW}dive not found, skipping${NC}"
fi
