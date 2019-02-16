Clear-Host

    function prompt
    {
        $PromptHost = [Environment]::MachineName
        $PromptUser = [Environment]::UserName
        function Format-CurrentPath ($Path)
        {
            # Some formatting choices
            switch -regex ($Path)
            {
                "^C:\\Users\\$PromptUser"
                {
                    $Path -replace "^C:\\Users\\$PromptUser", "~"
                    Continue
                }

                "^C:\\"
                {
                    $Path -replace "^C:\\", "\"
                    Continue
                }

                "^Microsoft.PowerShell.Core\\FileSystem\:\:"
                {
                    $Path -replace "^Microsoft.PowerShell.Core\\FileSystem\:\:"
                    Continue
                }

                default { $Path }
            }
        }

        $CurrentLocation = Format-CurrentPath -Path $ExecutionContext.SessionState.Path.CurrentLocation
        $SimulatedPrompt = "[$PromptHost][$PromptUser][$CurrentLocation]"
        $(
            if (Test-Path -Path "Variable:\PSDebugContext")
            {
                $('[DBG]: ' | Write-Host -ForegroundColor "Green" -NoNewline)
            }
            else
            {
                ''
            }
        ) + $("[$PromptHost]" | Write-Host -NoNewline -ForegroundColor "Green") + $($("[$PromptUser]" | Write-Host -NoNewline -ForegroundColor "Cyan") + $("[$CurrentLocation]" | Write-Host -ForegroundColor "Magenta" -NoNewline)) + " "
        if ($SimulatedPrompt.Length -ge 80) # I don't want to have my commands wrap on to another line just because of a long path.
        {
            " " + $(Write-Host "") + $("~>" | Write-Host -NoNewline) + " "
        }
        else
        {
            " "
        }
    }

# Aliases and preferences

    # Aliases
    $NewAliases = @(

        @{
            Name = "devicemanager"
            Value = "hdwwiz.cpl"
        }

        @{
            Name = "gd"
            Value = "Get-Date"
        }
    )

    forEach ($Alias in $NewAliases)
    {
        if (!(Test-Path -Path "alias:$Alias.Name"))
        {
            New-Alias -Name $Alias.Name -Value $Alias.Value
        }
    }

    # Preferences
    if (Get-Command Set-PSReadlineKeyHandler -ErrorAction "SilentlyContinue")
    {
        # Set zsh-style tab-complete:
        Set-PSReadlineKeyHandler -Key "Tab" -Function "MenuComplete"
    }