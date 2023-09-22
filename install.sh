#!/usr/bin/env bash
while [[ "$#" -gt 0 ]]
do
    case $1 in
        -b|--backup)
          BACKUP="true"
          ;;
        -s|--source)
          SOURCE="$2"
          ;;
        -h|--help)
          SHOW_HELP="true"
          ;;
    esac
    shift
done

if [[ "$BACKUP" == "" ]]; then
    BACKUP="false"
fi

if [[ "$SOURCE" == "" ]]; then
    dotfilesSource="$HOME/dotfiles"
else
    dotfilesSource=$SOURCE
fi
CurrentDate=$(date +"%Y%m%d_%H%M%S")

# Colours
NC='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

show_help()
{
    echo "usage: install.sh [-b|--backup] [-s|--source] [-h|--help]"
    echo ""
    echo "options:"
    echo "  -b, --backup Backs up existing dotfiles to prevent them being overwritten"
    echo "  -s, --source Explicitly defines a source for the dotfiles rather than assuming it is ~/dotfiles"
    echo "  -h, --help   Only shows this help message (unhelpfully)"
    echo ""
}

backup_dotfiles()
{
    if [[ "$BACKUP" == "true" ]]; then
        (BACKUP_LOCATION="$HOME/.backups/dotfiles/$CurrentDate" && \
        mkdir -p "$BACKUP_LOCATION" && \
        cp "$HOME/.bash_profile" "$BACKUP_LOCATION/.bash_profile" && \
        cp "$HOME/.profile" "$BACKUP_LOCATION/.profile" && \
        cp "$HOME/.bashrc" "$BACKUP_LOCATION/.bashrc" && \
        cp "$HOME/.aliases" "$BACKUP_LOCATION/.aliases" && \
        cp "$HOME/.config/bat/config" "$BACKUP_LOCATION/bat-config" && \
        cp "$HOME/.config/Code/User/settings.json" "$BACKUP_LOCATION/Code-settings.json" && \
        cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_LOCATION/Code-keybindings.json" && \
        cp "$HOME/.config/Code/User/snippets/ansible.json" "$BACKUP_LOCATION/Code-snippets-ansible.json" && \
        cp "$HOME/.config/Code/User/snippets/powershell.json" "$BACKUP_LOCATION/Code-snippets-powershell.json" && \
        cp "$HOME/.config/Code/User/snippets/python.json" "$BACKUP_LOCATION/Code-snippets-python.json" && \
        cp "$HOME/.gitconfig" "$BACKUP_LOCATION/.gitconfig" && \
        cp "$HOME/.config/powershell/profile.ps1" "$BACKUP_LOCATION/ps_profile.ps1" && \
        cp "$HOME/.ps_history.txt" "$BACKUP_LOCATION/.ps_history.txt" && \
        cp "$HOME/.config/starship.toml" "$BACKUP_LOCATION/starship.toml" && \
        cp "$HOME/.tmux.conf" "$BACKUP_LOCATION/.tmux.conf" && \
        cp "$HOME/.vimrc" "$BACKUP_LOCATION/.vimrc" && \
        cp "$HOME/.zshrc" "$BACKUP_LOCATION/.zshrc" && echo -e "✅ ${GREEN}Backed up${NC} dotfiles") \
        || echo -e "❌ ${RED}Error${NC} backing up dotfiles"
    fi
}

install_bash()
{
    ln -sf "$dotfilesSource/bash/bash_profile" "$HOME/.bash_profile" && \
    ln -sf "$dotfilesSource/bash/bash_profile" "$HOME/.profile"
    if [[ ($(cat "$HOME/.bash_profile") != "") && ($(cat "$HOME/.profile") != "") ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash profile"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash profile"
    fi

    ln -sf "$dotfilesSource/bash/bashrc" "$HOME/.bashrc"
    if [[ $(cat "$HOME/.bashrc") != ""  ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash rc"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash rc"
    fi

    ln -sf "$dotfilesSource/bash/aliases" "$HOME/.aliases"
    if [[ $(cat  "$HOME/.aliases") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} Bash aliases"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading Bash aliases"
    fi
}

install_bat()
{
    if [ -x "$(command -v bat)" ]; then
        mkdir -p "$HOME/.config/bat/"
        ln -sf "$dotfilesSource/bat/config" "$HOME/.config/bat/config"
        if [[ $(cat  "$HOME/.config/bat/config") != "" ]]; then
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
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        codeRoot="$HOME/.config/Code/"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        codeRoot="$HOME/Library/Application Support/Code/"
    fi

    if [ -x "$(command -v code)" ]; then
        mkdir -p "$codeRoot/User" && mkdir -p "$codeRoot/User/snippets/"
        ln -sf "$dotfilesSource/vscode/settings.json" "$codeRoot/User/settings.json"
        if [[ $(cat "$codeRoot/User/settings.json") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code settings"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code settings"
        fi

        ln -sf "$dotfilesSource/vscode/keybindings.json" "$codeRoot/User/keybindings.json"
        if [[ $(cat "$codeRoot/User/keybindings.json") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code keybindings"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code keybindings"
        fi

        ln -sf "$dotfilesSource/vscode/ansible.json" "$codeRoot/User/snippets/ansible.json"
        if [[ $(cat "$codeRoot/User/snippets/ansible.json") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Ansible snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Ansible snippets"
        fi

        ln -sf "$dotfilesSource/vscode/powershell.json" "$codeRoot/User/snippets/powershell.json"
        if [[ $(cat "$codeRoot/User/snippets/powershell.json") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Powershell snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Powershell snippets"
        fi

        ln -sf "$dotfilesSource/vscode/python.json" "$codeRoot/User/snippets/python.json"
        if [[ $(cat "$codeRoot/User/snippets/python.json") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} VS Code Python snippets"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading VS Code Python snippets"
        fi
    fi
}

install_git()
{
    ln -sf "$dotfilesSource/git/gitconfig" "$HOME/.gitconfig"
    touch "$HOME/.git_extras" # For extras not suitable for Git
    if [[ $(cat "$HOME/.gitconfig") != "" ]]; then
        echo -e "✅ ${GREEN}Installed${NC} git config"
    else
        echo -e "❌ ${RED}Error${NC} installing/reading git config"
    fi
}

install_pwsh()
{
    if [ -x "$(command -v pwsh)" ]; then
        mkdir -p "$HOME/.config/powershell"
        ln -sf "$dotfilesSource/pwsh/profile.ps1" "$HOME/.config/powershell/profile.ps1"
        if [[ $(cat "$HOME/.config/powershell/profile.ps1") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} pwsh profile"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading pwsh profile"
        fi

        mkdir -p "$HOME/.local/share/powershell/PSReadLine/"
        touch "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
        ln -sf "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt" "$HOME/.ps_history.txt"
        if [[ $(stat "$HOME/.ps_history.txt") != "" ]]; then
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
        mkdir -p "$HOME/.config"
        ln -sf "$dotfilesSource/starship/config.toml" "$HOME/.config/starship.toml"
        if [[ $(cat "$HOME/.config/starship.toml") != "" ]]; then
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
        ln -sf "$dotfilesSource/tmux/tmux.conf" "$HOME/.tmux.conf"
        if [[ $(cat "$HOME/.tmux.conf") != "" ]]; then
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
        ln -sf "$dotfilesSource/vim/vimrc" "$HOME/.vimrc"
        if [[ $(cat "$HOME/.vimrc") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} vim config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading vim config"
        fi

        plugins_dir="$HOME/.vim/pack/plugins/start"
        themes_dir="$HOME/.vim/pack/themes/start"
        mkdir -p "$plugins_dir"
        mkdir -p "$themes_dir"
        if [ -x "$(command -v git)" ]; then
            if [ ! -d "$plugins_dir/dracula" ]; then
                git clone --quiet "https://github.com/dracula/vim.git" "$plugins_dir/dracula"
                echo -e "✅ ${GREEN}Installed${NC} Dracula plugin"
            fi
            if [ ! -d "$plugins_dir/vim-airline" ]; then
                git clone --quiet "https://github.com/vim-airline/vim-airline.git" "$plugins_dir/vim-airline" && vim -u NONE -c "helptags $plugins_dir/vim-airline/doc" -c q
                echo -e "✅ ${GREEN}Installed${NC} vim-arline plugin"
            fi
            if [ ! -d "$plugins_dir/vim-ps1" ]; then
                git clone --quiet "https://github.com/PProvost/vim-ps1.git" "$plugins_dir/vim-ps1"
                echo -e "✅ ${GREEN}Installed${NC} vim-ps1 plugin"
            fi
            if [ ! -d "$plugins_dir/nerdtree" ]; then
                git clone --quiet "https://github.com/preservim/nerdtree.git" "$plugins_dir/nerdtree" && vim -u NONE -c "helptags $plugins_dir/nerdtree/doc" -c q
                echo -e "✅ ${GREEN}Installed${NC} nerdtree plugin"
            fi
            if [ ! -d "$plugins_dir/vim-startify" ]; then
                git clone --quiet "https://github.com/mhinz/vim-startify.git" "$plugins_dir/vim-startify"
                echo -e "✅ ${GREEN}Installed${NC} vim-startify plugin"
            fi
        else
            echo -e "🟨 ${YELLOW}Git not found, unable to clone and install packages${NC}"
        fi
    fi
}

install_zsh()
{
    if [ -x "$(command -v zsh)" ]; then
        ln -sf "$dotfilesSource/zsh/zshrc" "$HOME/.zshrc"
        if [[ $(cat "$HOME/.zshrc") != "" ]]; then
            echo -e "✅ ${GREEN}Installed${NC} zsh/oh-my-zsh config"
        else
            echo -e "❌ ${RED}Error${NC} installing/reading zsh/oh-my-zsh config"
        fi
        if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
            # auto suggestions
            if [[ ! -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
                git clone -q "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
            fi
            if [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
                echo -e "✅ ${GREEN}Installed${NC} zsh-autosuggestions plugin"
            else
                echo -e "❌ ${RED}Error${NC} installing/reading zsh-autosuggestions plugin"
            fi
            # syntax highlighting
            if [[ ! -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
                git clone -q "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
            fi
            if [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
                echo -e "✅ ${GREEN}Installed${NC} zsh-syntax-highlighting plugin"
            else
                echo -e "❌ ${RED}Error${NC} installing/reading zsh-syntax-highlighting plugin"
            fi
        fi
    else
        echo -e "🟨 ${YELLOW}zsh not found, skipping${NC}"
    fi
}

if [[ "$SHOW_HELP" != "" ]]; then
    show_help
else
    backup_dotfiles
    install_bash
    install_bat
    install_code
    install_git
    install_pwsh
    install_starship
    install_tmux
    install_vim
    install_zsh
fi
