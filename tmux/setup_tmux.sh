#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v tmux)" ]; then
    ln -sf "$DOTFILES_SOURCE/tmux/tmux.conf" "$HOME/.tmux.conf"

    if [[ $(cat "$HOME/.tmux.conf") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} tmux config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading tmux config"
    fi
else
    echo -e "🟨 ${YELLOW}tmux not found, skipping${NC}"
fi
