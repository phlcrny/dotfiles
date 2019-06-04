#!/usr/bin/env bash

# Treat this script as (at best) a work in progress.
#
# This script assumes that the repository is cloned to $HOME/dotfiles
# Adjust the path as required if this isn't right for you.

# bash
ln -sf ~dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~dotfiles/bash/bash_profile ~/.profile
ln -sf ~dotfiles/bash/bashrc ~/.bashrc
ln -sf ~dotfiles/bash/bash_aliases ~/.bash_aliases

# tmux
echo "tmux config"
ln -sf "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux default session"
ln -sf "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux-default"

# vim
echo "vim config"
ln -sf "$HOME/dotfiles/vim/vimrc" "$HOME/.vimrc"

# pwsh
if [-x "$(command -v pwsh)"]; then
    mkdir -p "$HOME/.config/powershell"
    echo "pwsh profile"
    ln -sf "$HOME/dotfiles/pwsh/profile.ps1" "$HOME/.config/powershell/profile.ps1"
    echo "PSReadline history"
    ln -sf "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt" "$HOME/.ps_history.txt"
fi

# vscode
if [-x "$(command -v code)"]; then
    mkdir -p "$HOME/.config/vscode"
    echo "Visual Studio Code settings"
    ln -sf "$HOME/dotfiles/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    echo "Visual Studio Code keybindings"
    ln -sf "$HOME/dotfiles/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
    echo "Visual Studio Code Ansible snippets"
    ln -sf "$HOME/dotfiles/vscode/ansible.json" "$HOME/.config/Code/User/snippets/ansible.json"
    echo "Visual Studio Code Powershell snippets"
    ln -sf "$HOME/dotfiles/vscode/powershell.json" "$HOME/.config/Code/User/snippets/powershell.json"
fi