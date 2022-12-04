#!/usr/bin/env bash
# This script assumes that the repository is cloned to ~/dotfiles
# Adjust the path as required if this isn't right for you.

# Base variables
dotfilesSource=~/dotfiles
CurrentDate=$(date +"%d-%b-%Y_%H%M%S")
# Colours
NC='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

if [[ "$1" == "backup" ]]; then
    cp ~/.bash_profile ~/.bash_profile_$CurrentDate.bak && \
    cp ~/.profile ~/.profile_$CurrentDate.bak && \
    cp ~/.bashrc ~/.bashrc_$CurrentDate.bak
    echo -e "✅ ${GREEN}Backed up${NC} Bash files"
fi

install_bash()
{
    ln -sf "$dotfilesSource/bash/bash_profile" ~/.bash_profile && \
    ln -sf "$dotfilesSource/bash/bash_profile" ~/.profile
    if [[ ($(cat ~/.bash_profile) != "") && ($(cat ~/.profile) != "") ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash profile"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash profile"
    fi

    ln -sf "$dotfilesSource/bash/bashrc" ~/.bashrc
    if [[ $(cat ~/.bashrc) != ""  ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash rc"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash rc"
    fi

    ln -sf "$dotfilesSource/bash/bash_aliases" ~/.bash_aliases
    if [[ $(cat  ~/.bash_aliases) != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash aliases"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash aliases"
    fi
}

install_bat()
{
    if [ -x "$(command -v bat)" ]; then
        mkdir -p ~/.config/bat/
        ln -sf $dotfilesSource/bat/config ~/.config/bat/config
        if [[ $(cat  ~/.config/bat/config) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} bat config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading bat config"
        fi
    else
        echo -e "🟨 ${YELLOW}bat not found, skipping${NC}"
    fi
}

install_code()
{
    if [ -x "$(command -v code)" ]; then
        mkdir -p ~/.config/Code/User && mkdir -p ~/.config/Code/User/snippets/
        ln -sf "$dotfilesSource/vscode/settings.json" ~/.config/Code/User/settings.json
        if [[ $(cat ~/.config/Code/User/settings.json) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code settings"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code settings"
        fi

        ln -sf "$dotfilesSource/vscode/keybindings.json" ~/.config/Code/User/keybindings.json
        if [[ $(cat ~/.config/Code/User/keybindings.json) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code keybindings"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code keybindings"
        fi

        ln -sf "$dotfilesSource/vscode/ansible.json" ~/.config/Code/User/snippets/ansible.json
        if [[ $(cat ~/.config/Code/User/snippets/ansible.json) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Ansible snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Ansible snippets"
        fi

        ln -sf "$dotfilesSource/vscode/powershell.json" ~/.config/Code/User/snippets/powershell.json
        if [[ $(cat ~/.config/Code/User/snippets/powershell.json) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Powershell snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Powershell snippets"
        fi

        ln -sf "$dotfilesSource/vscode/python.json" ~/.config/Code/User/snippets/python.json
        if [[ $(cat ~/.config/Code/User/snippets/python.json) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Python snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Python snippets"
        fi
    fi
}

install_git()
{
    ln -sf "$dotfilesSource/git/gitconfig" ~/.gitconfig
    touch ~/.git-extras # For extras not suitable for Git
    if [[ $(cat ~/.gitconfig) != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} git config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading git config"
    fi
}

install_pwsh()
{
    if [ -x "$(command -v pwsh)" ]; then
        mkdir -p ~/.config/powershell
        ln -sf "$dotfilesSource/pwsh/profile.ps1" ~/.config/powershell/profile.ps1
        if [[ $(cat ~/.config/powershell/profile.ps1) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} pwsh profile"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading pwsh profile"
        fi

        mkdir -p ~/.local/share/powershell/PSReadLine/
        ln -sf ~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt ~/.ps_history.txt
        if [[ $(stat ~/.ps_history.txt) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} PSReadline history symlink"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading PSReadline history symlink"
        fi
    else
        echo -e "🟨 ${YELLOW}pwsh not found, skipping${NC}"
    fi
}

install_starship()
{
    if [ -x "$(command -v starship)" ]; then
        mkdir -p ~/.config
        ln -sf $dotfilesSource/starship/config.toml ~/.config/starship.toml
        if [[ $(cat ~/.config/starship.toml) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} starship config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading starship config"
        fi
    else
        echo -e "🟨 ${YELLOW}starship not found, skipping${NC}"
    fi
}

install_tmux()
{
    if [ -x "$(command -v tmux)" ]; then
        ln -sf "$dotfilesSource/tmux/tmux.conf" ~/.tmux.conf
        if [[ $(cat ~/.tmux.conf) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} tmux config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading tmux config"
        fi
    else
        echo -e "🟨 ${YELLOW}tmux not found, skipping${NC}"
    fi
}

install_vim()
{
    if [ -x "$(command -v vim)" ]; then
        ln -sf "$dotfilesSource/vim/vimrc" ~/.vimrc
        if [[ $(cat ~/.vimrc) != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} vim config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading vim config"
        fi

        plugins_dir=~/.vim/pack/plugins/start
        themes_dir=~/.vim/pack/themes/start
        mkdir -p $plugins_dir
        mkdir -p $themes_dir
        if [ -x "$(command -v git)" ]; then
            if [ ! -d "$plugins_dir/dracula" ]; then
                git clone https://github.com/dracula/vim.git "$plugins_dir/dracula"
                echo -e "✅ ${GREEN}Installed${NC} Dracula"
            fi
            if [ ! -d "$plugins_dir/vim-airline" ]; then
                git clone https://github.com/vim-airline/vim-airline.git "$plugins_dir/vim-airline" && vim -u NONE -c "helptags $plugins_dir/vim-airline/doc" -c q
                echo -e "✅ ${GREEN}Installed${NC} vim-arline"
            fi
            if [ ! -d "$plugins_dir/vim-ps1" ]; then
                git clone https://github.com/PProvost/vim-ps1.git "$plugins_dir/vim-ps1"
                echo -e "✅ ${GREEN}Installed${NC} vim-ps1"
            fi
            if [ ! -d "$plugins_dir/nerdtree" ]; then
                git clone https://github.com/preservim/nerdtree.git "$plugins_dir/nerdtree" && vim -u NONE -c "helptags $plugins_dir/nerdtree/doc" -c q
                echo -e "✅ ${GREEN}Installed${NC} nerdtree"
            fi
        else
            echo -e "🟨 ${YELLOW}Git not found, unable to clone and install packages${NC}"
        fi
    fi
}

install_bash
install_bat
install_code
install_git
install_pwsh
install_starship
install_tmux
install_vim
