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

            default
            {
                $Path
            }
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

    if ($Null -ne (Get-Command "hdwwiz.cpl" -ErrorAction "SilentlyContinue"))
    {
        @{
            Name        = "devicemanager"
            Value       = "hdwwiz.cpl"
            Description = "Alias for the Device Manager Control Panel applet."
        }
    }

    @{
        Name        = "gd"
        Value       = "Get-Date"
        Description = "Short-hand for the Get-Date cmdlet."
    }

    @{
        Name        = "gfh"
        Value       = "Get-Help"
        Description = "Alias to replace an old custom function."
    }
)

forEach ($Alias in $NewAliases)
{
    if (-not (Test-Path -Path "alias:\$Alias.Name" -ErrorAction "SilentlyContinue"))
    {
        $AliasSplat = @{
            Name        = $Alias.Name
            Value       = $Alias.Value
            Description = $Alias.Description
        }

        New-Alias @AliasSplat
    }
}

# Preferences
if (Get-Command Set-PSReadlineKeyHandler -ErrorAction "SilentlyContinue")
{
    Set-PSReadlineKeyHandler -Key "Tab" -Function "MenuComplete"
    Set-PSReadlineKeyHandler -Chord "Ctrl+K" -Function "DeleteToEnd"
    Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
    Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"
    Set-PSReadlineOption -BellStyle "None"
}