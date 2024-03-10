#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v vim)" ]; then
    ln -sf "$DOTFILES_SOURCE/vim/vimrc" "$HOME/.vimrc"

    if [[ $(cat "$HOME/.vimrc") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} vim config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading vim config"
    fi

    PLUGINS_DIR="$HOME/.vim/pack/plugins/start"
    THEMES_DIR="$HOME/.vim/pack/themes/start"
    mkdir -p "$PLUGINS_DIR"
    mkdir -p "$THEMES_DIR"

    if [ -x "$(command -v git)" ]; then
        if [ ! -d "$PLUGINS_DIR/dracula" ]; then
            git clone --quiet "https://github.com/dracula/vim.git" "$PLUGINS_DIR/dracula"
            echo -e "✅ ${GREEN}Installed${NC} Dracula plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-airline" ]; then
            git clone --quiet "https://github.com/vim-airline/vim-airline.git" "$PLUGINS_DIR/vim-airline" && vim -u NONE -c "helptags $PLUGINS_DIR/vim-airline/doc" -c q
            echo -e "✅ ${GREEN}Installed${NC} vim-airline plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-airline-themes" ]; then
            git clone --quiet "https://github.com/vim-airline/vim-airline-themes.git" "$PLUGINS_DIR/vim-airline-themes"
            echo -e "✅ ${GREEN}Installed${NC} vim-airline-themes plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-ps1" ]; then
            git clone --quiet "https://github.com/PProvost/vim-ps1.git" "$PLUGINS_DIR/vim-ps1"
            echo -e "✅ ${GREEN}Installed${NC} vim-ps1 plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/nerdtree" ]; then
            git clone --quiet "https://github.com/preservim/nerdtree.git" "$PLUGINS_DIR/nerdtree" && vim -u NONE -c "helptags $PLUGINS_DIR/nerdtree/doc" -c q
            echo -e "✅ ${GREEN}Installed${NC} nerdtree plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-startify" ]; then
            git clone --quiet "https://github.com/mhinz/vim-startify.git" "$PLUGINS_DIR/vim-startify"
            echo -e "✅ ${GREEN}Installed${NC} vim-startify plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-fugitive" ]; then
            git clone --quiet "https://tpope.io/vim/fugitive.git" "$PLUGINS_DIR/vim-fugitive" && vim -u NONE -c "helptags $PLUGINS_DIR/fugitive/doc" -c q
            echo -e "✅ ${GREEN}Installed${NC} vim-fugitive plugin"
        fi

        if [ ! -d "$PLUGINS_DIR/vim-gitgutter" ]; then
            git clone --quiet "https://github.com/airblade/vim-gitgutter" "$PLUGINS_DIR/vim-gitgutter" && vim -u NONE -c "helptags $PLUGINS_DIR/vim-gitgutter/doc" -c q
            echo -e "✅ ${GREEN}Installed${NC} vim-gitgutter plugin"
        fi
    else
        echo -e "🟨 ${YELLOW}Git not found, unable to clone and install packages${NC}"
    fi
fi
