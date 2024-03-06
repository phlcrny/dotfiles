#!/bin/bash
if [ -z ${DOTFILES_SOURCE+x} ]; then
    echo "❌ Specify DOTFILES_SOURCE and run again"
    exit 1
fi

if [ -x "$(command -v zsh)" ]; then
    ln -sf "$DOTFILES_SOURCE/zsh/zshrc" "$HOME/.zshrc"

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
