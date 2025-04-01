#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

BACKUP=${BACKUP:=false}
SOURCE=${SOURCE:=$HOME/dotfiles}
SHOW_HELP=${SHOW_HELP:=false}

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -b | --backup)
        BACKUP="true"
        ;;
    -s | --source)
        SOURCE="$2"
        ;;
    -h | --help)
        SHOW_HELP="true"
        ;;
    esac
    shift
done

# Colours
NC='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

show_help() {
    echo "usage: install.sh [-b|--backup] [-s|--source] [-h|--help]"
    echo ""
    echo "options:"
    echo "  -b, --backup Backs up existing dotfiles to prevent them being overwritten"
    echo "  -s, --source Explicitly defines a source for the dotfiles rather than assuming it is ~/dotfiles"
    echo "  -h, --help   Only shows this help message (unhelpfully)"
    echo ""
}

backup_dotfiles() {
    echo "ℹ Creating backups..."
    CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
    (BACKUP_LOCATION="$HOME/.backups/dotfiles/$CURRENT_DATE" &&
        mkdir -p "$BACKUP_LOCATION" &&
        cp "$HOME/.bash_profile" "$BACKUP_LOCATION/.bash_profile" &&
        cp "$HOME/.profile" "$BACKUP_LOCATION/.profile" &&
        cp "$HOME/.bashrc" "$BACKUP_LOCATION/.bashrc" &&
        cp "$HOME/.aliases" "$BACKUP_LOCATION/.aliases" &&
        cp "$HOME/.config/bat/config" "$BACKUP_LOCATION/bat-config" &&
        cp "$HOME/.config/Code/User/settings.json" "$BACKUP_LOCATION/Code-settings.json" &&
        cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_LOCATION/Code-keybindings.json" &&
        cp "$HOME/.config/Code/User/snippets/powershell.json" "$BACKUP_LOCATION/Code-snippets-powershell.json" &&
        cp "$HOME/.config/Code/User/snippets/python.json" "$BACKUP_LOCATION/Code-snippets-python.json" &&
        cp "$HOME/.config/Code/User/snippets/yaml.json" "$BACKUP_LOCATION/Code-snippets-yaml.json" &&
        cp "$HOME/.gitconfig" "$BACKUP_LOCATION/.gitconfig" &&
        cp "$HOME/.config/powershell/profile.ps1" "$BACKUP_LOCATION/ps_profile.ps1" &&
        cp "$HOME/.ps_history.txt" "$BACKUP_LOCATION/.ps_history.txt" &&
        cp "$HOME/.config/starship.toml" "$BACKUP_LOCATION/starship.toml" &&
        cp "$HOME/.tmux.conf" "$BACKUP_LOCATION/.tmux.conf" &&
        cp "$HOME/.vimrc" "$BACKUP_LOCATION/.vimrc" &&
        cp "$HOME/.zshrc" "$BACKUP_LOCATION/.zshrc" && echo -e "✅ ${GREEN}Backed up${NC} dotfiles") ||
        echo -e "❌ ${RED}Error${NC} backing up dotfiles"
}

if [[ "$SHOW_HELP" == "true" ]]; then
    show_help
else
    set +u
    if [[ "$SOURCE" != "" && "$SOURCE" != "$HOME/dotfiles" ]]; then
        echo "ℹ Using '$SOURCE' specified --source parameter"
        export DOTFILES_SOURCE="$SOURCE"
    elif [ ! -z "$DOTFILES_SOURCE" ]; then
        echo "ℹ Using '$DOTFILES_SOURCE' via environment variable"
    else
        echo "ℹ Using '$SOURCE' via implicit default"
        export DOTFILES_SOURCE="$SOURCE"
    fi
    set -u

    if [[ -d "$DOTFILES_SOURCE" ]]; then

        if [[ "$BACKUP" == "true" ]]; then
            backup_dotfiles
        fi

        echo "ℹ Installing dotfiles..."
        find "$DOTFILES_SOURCE" -name 'setup_*.sh' -exec bash {} \;
    else
        echo "❌ Specified SOURCE '$DOTFILES_SOURCE' not found!"
        exit 1
    fi
fi
