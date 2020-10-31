@(
    [PSCustomObject]@{
        Source             = "$PSScriptRoot/powershell/profile.ps1"
        WindowsDestination = "C:/Users/$User/Documents/WindowsPowershell/profile.ps1"
        Description        = "Windows Powershell profile"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/pwsh/profile.ps1"
        WindowsDestination = "C:/Users/$User/Documents/Powershell/profile.ps1"
        UnixDestination    = "/home/$User/.config/powershell/profile.ps1"
        Description        = "Powershell (pwsh) profile"
    }

    [PSCustomObject]@{
        Source          = "/home/$User/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
        UnixDestination = "/home/$User/.ps_history.txt"
        Description     = "PSReadLine (Unix) history"
    }

    [PSCustomObject]@{
        Source             = "C:/Users/$User/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline/ConsoleHost_history.txt"
        WindowsDestination = "C:/Users/$User/.ps_history.txt"
        Description        = "PSReadLine (Windows) history"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/git/gitconfig"
        UnixDestination    = "/home/$User/.gitconfig"
        WindowsDestination = "C:/Users/$User/.gitconfig"
        Description        = "Git user config"
    }

    $( if (Test-Path "$PSScriptRoot/git/.git-identity" -ErrorAction "SilentlyContinue")
        {
            [PSCustomObject]@{
                Source             = "$PSScriptRoot/git/.git-identity"
                UnixDestination    = "/home/$User/.git-identity"
                WindowsDestination = "C:/Users/$User/.git-identity"
                Description        = "Git user identity"
            }
        }
    )

    [PSCustomObject]@{
        Source          = "$PSScriptRoot/tmux/.tmux.conf"
        UnixDestination = "/home/$User/.tmux.conf"
        Description     = "tmux config"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/settings.json"
        UnixDestination    = "/home/$User/.config/Code/User/settings.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/settings.json"
        Description        = "Visual Studio Code settings"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/keybindings.json"
        UnixDestination    = "/home/$User/.config/Code/User/keybindings.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/keybindings.json"
        Description        = "Visual Studio Code keybindings"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/ansible.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/ansible.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/ansible.json"
        Description        = "Visual Studio Code Ansible snippets"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/ansible.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/yaml.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/yaml.json"
        Description        = "Visual Studio Code YAML/Ansible snippets"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vscode/powershell.json"
        UnixDestination    = "/home/$User/.config/Code/User/snippets/powershell.json"
        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/powershell.json"
        Description        = "Visual Studio Code Powershell snippets"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/vim/vimrc"
        UnixDestination    = "/home/$User/.vimrc"
        WindowsDestination = "C:/Users/$User/_vimrc"
        Description        = "Vim config"
    }

    [PSCustomObject]@{
        Source             = "$PSScriptRoot/terminal/settings.json"
        WindowsDestination = "C:/Users/$User/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
        Description        = "Windows Terminal settings"
    }
)