#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v nvim)" ]; then

    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        mkdir -p "$HOME/.vim/autoload/"
        curl -s -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    mkdir -p "$HOME/.config/nvim"
    ln -sf "$DOTFILES_SOURCE/neovim/init.vim" "$HOME/.config/nvim/init.vim"

    if [[ $(cat "$HOME/.config/nvim/init.vim") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} neovim config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading neovim config"
    fi
else
    echo -e "🟨 ${YELLOW}neovim not found, skipping${NC}"
fi
