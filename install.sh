#!/usr/bin/env bash

# Treat this script as (at best) a work in progress.
#
# This script assumes that the repository is cloned to ~/dotfiles
# Adjust the path as required if this isn't right for you.
CurrentDate=$(date +"%d-%b-%Y_%H%M%S")
# bash
echo "Installing bash profile symlink"
cp ~/.bash_profile ~/.bash_profile_$CurrentDate.bak
ln -sf ~/dotfiles/bash/bash_profile ~/.bash_profile
echo "Installing Generic bash profile symlink"
ln -sf ~/dotfiles/bash/bash_profile ~/.profile
cp ~/.profile ~/.profile_$CurrentDate.bak
echo "Installing bashrc symlink"
ln -sf ~/dotfiles/bash/bashrc ~/.bashrc
cp ~/.bashrc ~/.bashrc_$CurrentDate.bak
echo "Installing bash aliases symlink"
ln -sf ~/dotfiles/bash/bash_aliases ~/.bash_aliases
# git
echo "Installing git config"
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
touch ~/.git-identity
# tmux
echo "Installing tmux config symlink"
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
# vim
echo "Installing vim config symlink"
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
# pwsh
if [ -x "$(command -v pwsh)" ]; then
    mkdir -p ~/.config/powershell
    echo "Installing pwsh profile symlink"
    ln -sf ~/dotfiles/pwsh/profile.ps1 ~/.config/powershell/profile.ps1
    echo "Installing PSReadline history symlink"
    mkdir -p ~/.local/share/powershell/PSReadLine/
    ln -sf ~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt ~/.ps_history.txt
fi
# vscode
if [ -x "$(command -v code)" ]; then
    mkdir -p ~/.config/Code/User
    echo "Installing Visual Studio Code settings symlink"
    ln -sf ~/dotfiles/vscode/settings.json ~/.config/Code/User/settings.json
    echo "Installing Visual Studio Code keybindings symlink"
    ln -sf ~/dotfiles/vscode/keybindings.json ~/.config/Code/User/keybindings.json
    echo "Installing Visual Studio Code Ansible snippets symlink"
    mkdir -p ~/.config/Code/User/snippets/
    ln -sf ~/dotfiles/vscode/ansible.json ~/.config/Code/User/snippets/ansible.json
    echo "Installing Visual Studio Code Powershell snippets symlink"
    ln -sf ~/dotfiles/vscode/powershell.json ~/.config/Code/User/snippets/powershell.json
    echo "Installing extensions"
    cat ~/dotfiles/vscode/extensions | xargs -L 1 code --install-extension
fi
# starship
if [ -x "$(command -v starship)" ]; then
    mkdir -p ~/.config
    echo "Installing starship config"
    ln -sf ~/dotfiles/starship/config.toml ~/.config/starship.toml
fi
# bat
if [ -x "$(command -v bat)" ]; then
    mkdir -p ~/.config/bat/
    echo "Installing bat config"
    ln -sf ~/dotfiles/bat/config ~/.config/bat/config
fi