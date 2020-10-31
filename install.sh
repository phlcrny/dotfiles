#!/usr/bin/env bash

# Treat this script as (at best) a work in progress.
#
# This script assumes that the repository is cloned to ~/dotfiles
# Adjust the path as required if this isn't right for you.

# bash
echo "bash profile"
ln -sf ~/dotfiles/bash/bash_profile ~/.bash_profile
echo "Generic bash profile"
ln -sf ~/dotfiles/bash/bash_profile ~/.profile
echo "bashrc"
ln -sf ~/dotfiles/bash/bashrc ~/.bashrc
echo "bash aliases"
ln -sf ~/dotfiles/bash/bash_aliases ~/.bash_aliases
# tmux
echo "tmux config"
ln -sf "~/dotfiles/tmux/tmux.conf" "~/.tmux.conf"
# vim
echo "vim config"
ln -sf "~/dotfiles/vim/vimrc" "~/.vimrc"
# pwsh
if [ -x "$(command -v pwsh)" ]; then
    mkdir -p "~/.config/powershell"
    echo "pwsh profile"
    ln -sf "~/dotfiles/pwsh/profile.ps1" "~/.config/powershell/profile.ps1"
    echo "PSReadline history"
    mkdir -p "~/.local/share/powershell/PSReadLine/"
    ln -sf "~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt" "~/.ps_history.txt"
fi
# vscode
if [ -x "$(command -v code)" ]; then
    mkdir -p "~/.config/Code/User"
    echo "Visual Studio Code settings"
    ln -sf "~/dotfiles/vscode/settings.json" "~/.config/Code/User/settings.json"
    echo "Visual Studio Code keybindings"
    ln -sf "~/dotfiles/vscode/keybindings.json" "~/.config/Code/User/keybindings.json"
    echo "Visual Studio Code Ansible snippets"
    mkdir -p "~/.config/Code/snippets"
    ln -sf "~/dotfiles/vscode/ansible.json" "~/.config/Code/User/snippets/ansible.json"
    echo "Visual Studio Code Powershell snippets"
    ln -sf "~/dotfiles/vscode/powershell.json" "~/.config/Code/User/snippets/powershell.json"
fi