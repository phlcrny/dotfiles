@(
    # Example
    # [PSCustomObject]@{
    #     Source             = ''
    #     MacDestination     = ''
    #     UnixDestination    = ''
    #     WindowsDestination = ''
    #     Description        = ''
    # }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/bat/config"
        MacDestination     = "/Users/$User/.config/bat/config"
        UnixDestination    = "/home/$User/.config/bat/config"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/bat/config"
        Description        = 'Bat config'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/git/gitconfig"
        MacDestination     = "/Users/$User/.gitconfig"
        UnixDestination    = "/home/$User/.gitconfig"
        WindowsDestination = "C:/Users/$User/.gitconfig"
        Description        = 'Git user config'
    }

    $( if (Test-Path "$PSScriptRoot/git/.git-extras" -ErrorAction 'SilentlyContinue')
        {
            [PSCustomObject]@{
                Source             = "$PSScriptRoot/git/.git-extras"
                MacDestination     = "/Users/$User/.git-extras"
                UnixDestination    = "/home/$User/.git-extras"
                WindowsDestination = "C:/Users/$User/.git-extras"
                Description        = 'Git extras not for source-control/defaults'
            }
        }
    )

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/powershell/profile.ps1"
        MacDestination     = $Null
        UnixDestination    = $Null
        WindowsDestination = "C:/Users/$User/Documents/WindowsPowershell/profile.ps1"
        Description        = 'Windows Powershell profile'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/pwsh/profile.ps1"
        MacDestination     = "/Users/$User/.config/powershell/profile.ps1"
        UnixDestination    = "/home/$User/.config/powershell/profile.ps1"
        WindowsDestination = "C:/Users/$User/Documents/Powershell/profile.ps1"
        Description        = 'Powershell (pwsh) profile'
    }

    [PSCustomObject]@{
        Source             = "/home/$User/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
        MacDestination     = "/Users/$User/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
        UnixDestination    = "/home/$User/.ps_history.txt"
        WindowsDestination = $Null
        Description        = 'PSReadLine (Unix) history'
    }

    [PSCustomObject]@{
        Source             = "C:/Users/$User/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline/ConsoleHost_history.txt"
        MacDestination     = $Null
        UnixDestination    = $Null
        WindowsDestination = "C:/Users/$User/.ps_history.txt"
        Description        = 'PSReadLine (Windows) history'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/starship/config.toml"
        MacDestination     = "/Users/$User/.config/starship.toml"
        UnixDestination    = "/home/$User/.config/starship.toml"
        WindowsDestination = "C:/Users/$User/.config/starship.toml"
        Description        = 'starship config'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/tmux/tmux.conf"
        MacDestination     = "/Users/$User/.tmux.conf"
        UnixDestination    = "/home/$User/.tmux.conf"
        WindowsDestination = $Null
        Description        = 'tmux config'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/settings.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/settings.json"
        UnixDestination    = "/home/$User/.config/Code/User/settings.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/settings.json"
        Description        = 'Visual Studio Code settings'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/keybindings.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/keybindings.json"
        UnixDestination    = "/home/$User/.config/Code/User/keybindings.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/keybindings.json"
        Description        = 'Visual Studio Code keybindings'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/ansible.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/snippets/ansible.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/ansible.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/ansible.json"
        Description        = 'Visual Studio Code Ansible snippets'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/ansible.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/snippets/yaml.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/yaml.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/yaml.json"
        Description        = 'Visual Studio Code YAML/Ansible snippets'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/powershell.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/snippets/powershell.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/powershell.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/powershell.json"
        Description        = 'Visual Studio Code Powershell snippets'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/python.json"
        MacDestination     = "/Users/$User/Library/Application Support/Code/User/snippets/python.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/python.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/python.json"
        Description        = 'Visual Studio Code Python snippets'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vim/vimrc"
        MacDestination     = "/Users/$User/.vimrc"
        UnixDestination    = "/home/$User/.vimrc"
        WindowsDestination = "C:/Users/$User/_vimrc"
        Description        = 'Vim config'
    }

    [PSCustomObject]@{
        Source             = $Null
        MacDestination     = "/Users/$User/.vim/pack/plugins/start"
        UnixDestination    = "/home/$User/.vim/pack/plugins/start"
        WindowsDestination = "C:/Users/$User/.vim/pack/start/opt"
        Description        = "Vim plugins directory"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/terminal/settings.json"
        MacDestination     = $Null
        UnixDestination    = $Null
        WindowsDestination = "C:/Users/$User/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
        Description        = 'Windows Terminal settings'
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/zsh/zshrc"
        MacDestination     = "/Users/$User/.zshrc"
        UnixDestination    = "/home/$User/.zshrc"
        WindowsDestination = $Null
        Description        = '.zshrc'
    }
)
