#!/usr/bin/env bash

# Treat this script as a work in progress.
#
#
# This script assumes that the repository is cloned to $HOME/dotfiles
# Adjust the path as required if this isn't right for you.

echo "pwsh profile"
ln -sf "$HOME/dotfiles/pwsh/profile.ps1" "$HOME/.config/powershell/profile.ps1"
echo "PSReadline history"
ln -sf "$HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt" "$HOME/.ps_history.txt"
echo "tmux config"
ln -sf "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "tmux default session"
ln -sf "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux-default"
echo "Visual Studio Code settings"
ln -sf "$HOME/dotfiles/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
echo "Visual Studio Code keybindings"
ln -sf "$HOME/dotfiles/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
echo "Visual Studio Code Ansible snippets"
ln -sf "$HOME/dotfiles/vscode/ansible.json" "$HOME/.config/Code/User/snippets/ansible.json"
echo "Visual Studio Code Powershell snippets"
ln -sf "$HOME/dotfiles/vscode/powershell.json" "$HOME/.config/Code/User/snippets/powershell.json"
echo "Vim config"
ln -sf "$HOME/dotfiles/vim/vimrc" "$HOME/.vimrc"