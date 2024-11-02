#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v wezterm)" ]; then
    ln -sf "$DOTFILES_SOURCE/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

    if [[ ! -f "$HOME/.config/wezterm/wezterm_extras.lua" ]]; then
        mkdir -p "$HOME/.config/wezterm" && touch "$HOME/.config/wezterm/wezterm_extras.lua"
    fi

    if [[ $(cat "$HOME/.wezterm.lua") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} wezterm config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading wezterm config"
    fi
else
    echo -e "🟨 ${YELLOW}wezterm not found, skipping${NC}"
fi
