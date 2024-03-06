#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

ln -sf "$DOTFILES_SOURCE/git/gitconfig" "$HOME/.gitconfig"
touch "$HOME/.git_extras"

if [[ $(cat "$HOME/.gitconfig") != "" ]]; then
    echo -e "✅ ${GREEN}Installed${NC} git config"
else
    echo -e "❌ ${RED}Error${NC} installing/reading git config"
fi
