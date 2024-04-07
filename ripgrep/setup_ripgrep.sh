#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

ln -sf "$DOTFILES_SOURCE/ripgrep/ripgreprc" "$HOME/.ripgreprc"
if [[ $(cat "$HOME/.ripgreprc") != "" ]]; then
    echo -e "✅ ${GREEN}Installed${NC} ripgrep config"
else
    echo -e "❌ ${RED}Error${NC} installing/reading ripgrep config"
fi
