#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

ln -sf "$DOTFILES_SOURCE/bash/bash_profile" "$HOME/.bash_profile" && ln -sf "$DOTFILES_SOURCE/bash/bash_profile" "$HOME/.profile"

if [[ ($(cat "$HOME/.bash_profile") != "") && ($(cat "$HOME/.profile") != "") ]]; then
    echo -e "✅ ${GREEN}Installed${NC} Bash profile"
else
    echo -e "❌ ${RED}Error${NC} installing/reading Bash profile"
fi

ln -sf "$DOTFILES_SOURCE/bash/bashrc" "$HOME/.bashrc"
if [[ $(cat "$HOME/.bashrc") != "" ]]; then
    echo -e "✅ ${GREEN}Installed${NC} Bash rc"
else
    echo -e "❌ ${RED}Error${NC} installing/reading Bash rc"
fi

ln -sf "$DOTFILES_SOURCE/bash/aliases" "$HOME/.aliases"
if [[ $(cat "$HOME/.aliases") != "" ]]; then
    echo -e "✅ ${GREEN}Installed${NC} Bash aliases"
else
    echo -e "❌ ${RED}Error${NC} installing/reading Bash aliases"
fi
