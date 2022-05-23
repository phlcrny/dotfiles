#!/usr/bin/env bash
# This script assumes that the repository is cloned to ~/dotfiles
# Adjust the path as required if this isn't right for you.

dotfilesSource=~/dotfiles
CurrentDate=$(date +"%d-%b-%Y_%H%M%S")
# bash
echo "Installing bash profile symlink..."
cp ~/.bash_profile ~/.bash_profile_$CurrentDate.bak
ln -sf "$dotfilesSource/bash/bash_profile" ~/.bash_profile
echo "Installing Generic bash profile symlink..."
ln -sf "$dotfilesSource/bash/bash_profile" ~/.profile
cp ~/.profile ~/.profile_$CurrentDate.bak
echo "Installing bashrc symlink..."
ln -sf "$dotfilesSource/bash/bashrc" ~/.bashrc
cp ~/.bashrc ~/.bashrc_$CurrentDate.bak
echo "Installing bash aliases symlink..."
ln -sf "$dotfilesSource/bash/bash_aliases" ~/.bash_aliases
# git
echo "Installing git config"
ln -sf "$dotfilesSource/git/gitconfig" ~/.gitconfig
touch ~/.git-extras # For extras not suitable for Git
# tmux
if [ -x "$(command -v tmux)" ]; then
    echo "Installing tmux config symlink..."
    ln -sf "$dotfilesSource/tmux/tmux.conf" ~/.tmux.conf
else
    echo "tmux not found, skipping"
fi
# vim
if [ -x "$(command -v vim)" ]; then
    echo "Installing vim config symlink..."
    ln -sf "$dotfilesSource/vim/vimrc" ~/.vimrc
    echo "Creating vim packages file structure..."
    plugins_dir=~/.vim/pack/plugins/start
    themes_dir=~/.vim/pack/themes/start
    mkdir -p $plugins_dir
    mkdir -p $themes_dir
    echo "Installing vim plugins..."
    if [ -x "$(command -v git)" ]; then
        echo "Installing Dracula..."
        git clone https://github.com/dracula/vim.git "$plugins_dir/dracula"
        echo "Installing vim-airline..."
        git clone https://github.com/vim-airline/vim-airline.git "$plugins_dir/vim-airline" && vim -u NONE -c "helptags $plugins_dir/vim-airline/doc" -c q
        echo "Installing vim-ps1..."
        git clone https://github.com/PProvost/vim-ps1.git "$plugins_dir/vim-ps1"
        echo "Installing nerdtree..."
        git clone https://github.com/preservim/nerdtree.git "$plugins_dir/nerdtree" && vim -u NONE -c "helptags $plugins_dir/nerdtree/doc" -c q
    else
        echo "Git not found, unable to clone and install packages"
    fi
fi
# pwsh
if [ -x "$(command -v pwsh)" ]; then
    mkdir -p ~/.config/powershell
    echo "Installing pwsh profile symlink..."
    ln -sf "$dotfilesSource/pwsh/profile.ps1" ~/.config/powershell/profile.ps1
    echo "Installing PSReadline history symlink..."
    mkdir -p ~/.local/share/powershell/PSReadLine/
    ln -sf ~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt ~/.ps_history.txt
else
    echo "pwsh not found, skipping"
fi
# vscode
if [ -x "$(command -v code)" ]; then
    mkdir -p ~/.config/Code/User
    echo "Installing Visual Studio Code settings symlink..."
    ln -sf "$dotfilesSource/vscode/settings.json" ~/.config/Code/User/settings.json
    echo "Installing Visual Studio Code keybindings symlink..."
    ln -sf "$dotfilesSource/vscode/keybindings.json" ~/.config/Code/User/keybindings.json
    echo "Installing Visual Studio Code Ansible snippets symlink..."
    mkdir -p ~/.config/Code/User/snippets/
    ln -sf "$dotfilesSource/vscode/ansible.json" ~/.config/Code/User/snippets/ansible.json
    echo "Installing Visual Studio Code Powershell snippets symlink..."
    ln -sf "$dotfilesSource/vscode/powershell.json" ~/.config/Code/User/snippets/powershell.json
    echo "Installing Visual Studio Code Python snippets symlink..."
    ln -sf "$dotfilesSource/vscode/python.json" ~/.config/Code/User/snippets/python.json
fi
# starship
if [ -x "$(command -v starship)" ]; then
    mkdir -p ~/.config
    echo "Installing starship config..."
    ln -sf $dotfilesSource/starship/config.toml ~/.config/starship.toml
else
    echo "starship not found, skipping"
fi